"""
httpx auth - authentication handlers for HTTP requests.
"""
import hashlib
import os
import re
import time
from base64 import b64encode
from typing import Any, Dict, Generator, Optional, Tuple, Union

from .models import Request, Response
from .exceptions import RequestError


class Auth:
    """
    Base class for authentication handlers.

    An authentication handler acts as a callable that takes a request and
    yields one or more requests with auth applied, then processes the response.
    """
    requires_request_body = False
    requires_response_body = False

    def auth_flow(self, request: Request) -> Generator[Request, Response, None]:
        """
        Execute the authentication flow. Subclasses should override this method.
        """
        yield request

    def __call__(self, request: Request) -> Generator[Request, Response, None]:
        return self.auth_flow(request)


class BasicAuth(Auth):
    """
    HTTP Basic Authentication.
    Sends credentials as a base64-encoded username:password header.
    """
    def __init__(self, username: Union[str, bytes], password: Union[str, bytes]) -> None:
        if isinstance(username, str):
            username = username.encode("latin1")
        if isinstance(password, str):
            password = password.encode("latin1")
        self.username = username
        self.password = password

    def auth_flow(self, request: Request) -> Generator[Request, Response, None]:
        token = b64encode(b":".join((self.username, self.password))).decode("ascii")
        request.headers["Authorization"] = f"Basic {token}"
        yield request


class DigestAuth(Auth):
    """
    HTTP Digest Authentication.
    More complex than Basic - involves a challenge-response handshake.
    """
    requires_response_body = True

    def __init__(self, username: str, password: str) -> None:
        self.username = username
        self.password = password
        self._nonce_count: int = 0
        self._challenge: Optional[Dict[str, str]] = None

    def auth_flow(self, request: Request) -> Generator[Request, Response, None]:
        if self._challenge is not None:
            request = self._build_auth_header(request, self._challenge)

        response = yield request

        if response.status_code == 401:
            self._challenge = self._parse_challenge(response)
            request = self._build_auth_header(request, self._challenge)
            yield request

    def _parse_challenge(self, response: Response) -> Dict[str, str]:
        """Parse the WWW-Authenticate header into a challenge dict."""
        header = response.headers.get("www-authenticate", "")
        challenge: Dict[str, str] = {}
        for match in re.finditer(r'(\w+)="([^"]*)"', header):
            challenge[match.group(1)] = match.group(2)
        return challenge

    def _build_auth_header(self, request: Request, challenge: Dict[str, str]) -> Request:
        """Build a Digest Authorization header."""
        self._nonce_count += 1
        realm = challenge.get("realm", "")
        nonce = challenge.get("nonce", "")
        qop = challenge.get("qop", "")
        opaque = challenge.get("opaque", "")
        algorithm = challenge.get("algorithm", "MD5")

        cnonce = self._generate_cnonce()
        nc = f"{self._nonce_count:08x}"

        ha1 = hashlib.md5(
            f"{self.username}:{realm}:{self.password}".encode()
        ).hexdigest()
        ha2 = hashlib.md5(
            f"{request.method}:{request.url.path}".encode()
        ).hexdigest()

        if qop in ("auth", "auth-int"):
            response_digest = hashlib.md5(
                f"{ha1}:{nonce}:{nc}:{cnonce}:{qop}:{ha2}".encode()
            ).hexdigest()
        else:
            response_digest = hashlib.md5(
                f"{ha1}:{nonce}:{ha2}".encode()
            ).hexdigest()

        auth_parts = [
            f'Digest username="{self.username}"',
            f'realm="{realm}"',
            f'nonce="{nonce}"',
            f'uri="{request.url.path}"',
            f'response="{response_digest}"',
        ]
        if opaque:
            auth_parts.append(f'opaque="{opaque}"')
        if qop:
            auth_parts.append(f'qop={qop}')
            auth_parts.append(f'nc={nc}')
            auth_parts.append(f'cnonce="{cnonce}"')

        request.headers["Authorization"] = ", ".join(auth_parts)
        return request

    def _generate_cnonce(self) -> str:
        return hashlib.md5(str(time.time()).encode()).hexdigest()[:8]


class BearerAuth(Auth):
    """
    HTTP Bearer Token Authentication.
    """
    def __init__(self, token: str) -> None:
        self.token = token

    def auth_flow(self, request: Request) -> Generator[Request, Response, None]:
        request.headers["Authorization"] = f"Bearer {self.token}"
        yield request


class NetRCAuth(Auth):
    """
    Use a .netrc file for authentication credentials.
    """
    def __init__(self, file: Optional[str] = None) -> None:
        self._netrc_file = file
        self._credentials: Dict[str, Tuple[str, str]] = {}
        self._load_netrc()

    def _load_netrc(self) -> None:
        """Load credentials from the .netrc file."""
        netrc_path = self._netrc_file or os.path.expanduser("~/.netrc")
        try:
            with open(netrc_path) as f:
                content = f.read()
            # Simplified netrc parsing
            lines = content.split()
            i = 0
            current_machine = None
            current_login = None
            while i < len(lines):
                if lines[i] == "machine" and i + 1 < len(lines):
                    current_machine = lines[i + 1]
                    i += 2
                elif lines[i] == "login" and i + 1 < len(lines):
                    current_login = lines[i + 1]
                    i += 2
                elif lines[i] == "password" and i + 1 < len(lines) and current_machine and current_login:
                    self._credentials[current_machine] = (current_login, lines[i + 1])
                    i += 2
                else:
                    i += 1
        except FileNotFoundError:
            pass

    def auth_flow(self, request: Request) -> Generator[Request, Response, None]:
        host = request.url.host
        if host in self._credentials:
            username, password = self._credentials[host]
            token = b64encode(f"{username}:{password}".encode()).decode("ascii")
            request.headers["Authorization"] = f"Basic {token}"
        yield request


def build_auth_header(
    auth: Optional[Union[Auth, Tuple[str, str]]],
    request: Request
) -> Optional[str]:
    """
    Utility to build an auth header from an auth object or (user, pass) tuple.
    """
    if auth is None:
        return None
    if isinstance(auth, tuple):
        username, password = auth
        token = b64encode(f"{username}:{password}".encode()).decode("ascii")
        return f"Basic {token}"
    # For Auth instances, delegate to the auth_flow generator
    gen = auth.auth_flow(request)
    try:
        next(gen)
    except StopIteration:
        pass
    return request.headers.get("Authorization")
