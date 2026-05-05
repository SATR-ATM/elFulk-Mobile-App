"""
httpx client - the main HTTP client classes (sync and async).
"""
import time
from contextlib import contextmanager, asynccontextmanager
from typing import (
    Any, AsyncIterator, Callable, Dict, Generator, Iterator,
    List, Optional, Tuple, Type, Union
)

from .auth import Auth, BasicAuth, BearerAuth, build_auth_header
from .models import URL, Cookies, Headers, Request, Response
from .exceptions import (
    TooManyRedirects,
    HTTPStatusError,
    InvalidURL,
    ProxyError,
    TransportError,
    ConnectTimeout,
    ReadTimeout,
)
from .utils import (
    get_environment_proxies,
    same_origin,
    should_not_be_proxied,
    obfuscate_sensitive_headers,
    timer,
    parse_scheme,
)


DEFAULT_TIMEOUT = 5.0
DEFAULT_MAX_REDIRECTS = 20
DEFAULT_HEADERS = {
    "User-Agent": "python-httpx/0.27.0",
    "Accept": "*/*",
    "Accept-Encoding": "gzip, deflate, br",
    "Connection": "keep-alive",
}


class Timeout:
    """
    Timeout configuration for an HTTP request.
    Timeout values are in seconds.
    """
    def __init__(
        self,
        timeout: Optional[Union[float, "Timeout"]] = DEFAULT_TIMEOUT,
        *,
        connect: Optional[float] = None,
        read: Optional[float] = None,
        write: Optional[float] = None,
        pool: Optional[float] = None,
    ) -> None:
        if isinstance(timeout, Timeout):
            self.connect = timeout.connect
            self.read = timeout.read
            self.write = timeout.write
            self.pool = timeout.pool
        else:
            self.connect = connect if connect is not None else timeout
            self.read = read if read is not None else timeout
            self.write = write if write is not None else timeout
            self.pool = pool if pool is not None else timeout

    def __repr__(self) -> str:
        return (
            f"Timeout(connect={self.connect}, read={self.read}, "
            f"write={self.write}, pool={self.pool})"
        )


class Limits:
    """
    Configuration for connection pool limits.
    """
    def __init__(
        self,
        *,
        max_connections: Optional[int] = 100,
        max_keepalive_connections: Optional[int] = 20,
        keepalive_expiry: Optional[float] = 5.0,
    ) -> None:
        self.max_connections = max_connections
        self.max_keepalive_connections = max_keepalive_connections
        self.keepalive_expiry = keepalive_expiry

    def __repr__(self) -> str:
        return (
            f"Limits(max_connections={self.max_connections}, "
            f"max_keepalive_connections={self.max_keepalive_connections})"
        )


class BaseClient:
    """
    Base class for sync and async HTTP clients. Handles shared state:
    auth, cookies, headers, redirects, timeouts, proxies.
    """
    def __init__(
        self,
        *,
        auth: Optional[Union[Auth, Tuple[str, str]]] = None,
        params: Optional[Dict] = None,
        headers: Optional[Dict] = None,
        cookies: Optional[Dict] = None,
        verify: Union[bool, str] = True,
        cert: Optional[Union[str, Tuple[str, str]]] = None,
        timeout: Union[float, Timeout] = DEFAULT_TIMEOUT,
        follow_redirects: bool = False,
        max_redirects: int = DEFAULT_MAX_REDIRECTS,
        event_hooks: Optional[Dict[str, List[Callable]]] = None,
        base_url: Union[str, URL] = "",
        trust_env: bool = True,
    ) -> None:
        if isinstance(auth, tuple):
            auth = BasicAuth(*auth)
        self._auth = auth
        self._params = params or {}
        self._base_url = URL(base_url) if isinstance(base_url, str) else base_url
        self._headers = Headers({**DEFAULT_HEADERS, **(headers or {})})
        self._cookies = Cookies(cookies)
        self._verify = verify
        self._cert = cert
        self._timeout = Timeout(timeout) if isinstance(timeout, float) else timeout
        self._follow_redirects = follow_redirects
        self._max_redirects = max_redirects
        self._event_hooks: Dict[str, List[Callable]] = event_hooks or {"request": [], "response": []}
        self._trust_env = trust_env
        self._state = "unopened"  # "unopened", "opened", "closed"

    def _build_request(
        self,
        method: str,
        url: Union[str, URL],
        *,
        content: Optional[bytes] = None,
        data: Optional[Any] = None,
        json: Optional[Any] = None,
        params: Optional[Dict] = None,
        headers: Optional[Dict] = None,
        cookies: Optional[Dict] = None,
        auth: Optional[Union[Auth, Tuple[str, str]]] = None,
    ) -> Request:
        """Build a Request object from method, URL, and keyword args."""
        if isinstance(url, str):
            url = URL(url)

        merged_headers = dict(self._headers)
        if headers:
            merged_headers.update(headers)

        request = Request(
            method=method,
            url=url,
            headers=merged_headers,
            content=content,
            data=data,
            json=json,
        )
        return request

    def _merge_cookies(self, cookies: Optional[Dict]) -> Cookies:
        """Merge per-request cookies with client-level cookies."""
        merged = Cookies(dict(self._cookies))
        if cookies:
            for k, v in cookies.items():
                merged.set(k, v)
        return merged

    def _check_url_scheme(self, url: URL) -> None:
        """Validate that the URL uses a supported scheme."""
        scheme = url.scheme
        if scheme not in ("http", "https"):
            raise UnsupportedProtocol(  # type: ignore[name-defined]
                f"Unsupported URL scheme {scheme!r}"
            )

    def _should_follow_redirect(self, response: Response, request: Request) -> bool:
        """Determine if the client should follow a redirect response."""
        return (
            self._follow_redirects
            and response.is_redirect
            and "Location" in response.headers
        )

    def _build_redirect_request(self, request: Request, response: Response) -> Request:
        """Build a new request to follow a redirect."""
        location = response.headers.get("Location", "")
        url = URL(location)
        method = request.method
        # POST/PUT to GET for 303; also for 301/302 (common behavior)
        if response.status_code in (301, 302, 303) and method in ("POST", "PUT", "PATCH"):
            method = "GET"
        return Request(method=method, url=url, headers=request.headers)

    def _merge_environment_settings(
        self,
        url: URL,
        proxies: Optional[Dict] = None,
        stream: bool = False,
        verify: Optional[bool] = None,
        cert: Optional[Any] = None,
    ) -> Dict[str, Any]:
        """Merge environment settings for verify, proxies, etc."""
        env_proxies = get_environment_proxies() if self._trust_env else {}
        merged_proxies = {**env_proxies, **(proxies or {})}
        return {
            "verify": verify if verify is not None else self._verify,
            "cert": cert or self._cert,
            "proxies": merged_proxies,
        }

    @property
    def is_closed(self) -> bool:
        return self._state == "closed"

    @property
    def auth(self) -> Optional[Auth]:
        return self._auth

    @auth.setter
    def auth(self, auth: Union[Auth, Tuple[str, str]]) -> None:
        if isinstance(auth, tuple):
            auth = BasicAuth(*auth)
        self._auth = auth

    @property
    def base_url(self) -> URL:
        return self._base_url

    @property
    def headers(self) -> Headers:
        return self._headers

    @property
    def cookies(self) -> Cookies:
        return self._cookies

    @property
    def timeout(self) -> Timeout:
        return self._timeout

    @property
    def follow_redirects(self) -> bool:
        return self._follow_redirects


class Client(BaseClient):
    """
    An HTTP client. Usage::

        with httpx.Client() as client:
            response = client.get('https://example.com')
    """
    def __init__(self, **kwargs: Any) -> None:
        super().__init__(**kwargs)
        self._transport: Optional[Any] = None  # sync transport

    def __enter__(self) -> "Client":
        self._state = "opened"
        return self

    def __exit__(self, *args: Any) -> None:
        self.close()

    def close(self) -> None:
        """Close the HTTP client and release resources."""
        if self._transport:
            self._transport.close()
        self._state = "closed"

    def _send_single_request(self, request: Request) -> Response:
        """Send a single request (no redirect following)."""
        if self._transport is None:
            raise RuntimeError("Client not opened. Use 'with client:' context manager.")
        with timer() as t:
            response = self._transport.handle_request(request)
        response._elapsed = t["elapsed"]
        return response

    def send(
        self,
        request: Request,
        *,
        stream: bool = False,
        auth: Optional[Union[Auth, Tuple[str, str]]] = None,
        follow_redirects: Optional[bool] = None,
    ) -> Response:
        """Send a request and return the response."""
        follow = follow_redirects if follow_redirects is not None else self._follow_redirects
        response = self._send_single_request(request)
        history: List[Response] = []
        redirect_count = 0

        while self._should_follow_redirect(response, request) and follow:
            if redirect_count >= self._max_redirects:
                raise TooManyRedirects(
                    f"Exceeded {self._max_redirects} redirects.", request=request
                )
            history.append(response)
            request = self._build_redirect_request(request, response)
            response = self._send_single_request(request)
            redirect_count += 1

        response.history = history  # type: ignore[attr-defined]
        if not stream:
            response.read()
        return response

    def get(self, url: Union[str, URL], **kwargs: Any) -> Response:
        return self.request("GET", url, **kwargs)

    def post(self, url: Union[str, URL], **kwargs: Any) -> Response:
        return self.request("POST", url, **kwargs)

    def put(self, url: Union[str, URL], **kwargs: Any) -> Response:
        return self.request("PUT", url, **kwargs)

    def patch(self, url: Union[str, URL], **kwargs: Any) -> Response:
        return self.request("PATCH", url, **kwargs)

    def delete(self, url: Union[str, URL], **kwargs: Any) -> Response:
        return self.request("DELETE", url, **kwargs)

    def head(self, url: Union[str, URL], **kwargs: Any) -> Response:
        return self.request("HEAD", url, **kwargs)

    def options(self, url: Union[str, URL], **kwargs: Any) -> Response:
        return self.request("OPTIONS", url, **kwargs)

    def request(
        self,
        method: str,
        url: Union[str, URL],
        *,
        content: Optional[bytes] = None,
        data: Optional[Any] = None,
        json: Optional[Any] = None,
        params: Optional[Dict] = None,
        headers: Optional[Dict] = None,
        cookies: Optional[Dict] = None,
        auth: Optional[Union[Auth, Tuple[str, str]]] = None,
        follow_redirects: Optional[bool] = None,
        timeout: Optional[Union[float, Timeout]] = None,
        stream: bool = False,
    ) -> Response:
        """Build and send an HTTP request."""
        request = self._build_request(
            method=method,
            url=url,
            content=content,
            data=data,
            json=json,
            params=params,
            headers=headers,
            cookies=cookies,
        )
        return self.send(request, stream=stream, auth=auth, follow_redirects=follow_redirects)


class AsyncClient(BaseClient):
    """
    An async HTTP client. Usage::

        async with httpx.AsyncClient() as client:
            response = await client.get('https://example.com')
    """
    def __init__(self, **kwargs: Any) -> None:
        super().__init__(**kwargs)
        self._async_transport: Optional[Any] = None

    async def __aenter__(self) -> "AsyncClient":
        self._state = "opened"
        return self

    async def __aexit__(self, *args: Any) -> None:
        await self.aclose()

    async def aclose(self) -> None:
        """Close the async HTTP client."""
        if self._async_transport:
            await self._async_transport.aclose()
        self._state = "closed"

    async def _send_single_request(self, request: Request) -> Response:
        """Send a single async request."""
        if self._async_transport is None:
            raise RuntimeError("AsyncClient not opened. Use 'async with client:' context manager.")
        response = await self._async_transport.handle_async_request(request)
        return response

    async def send(
        self,
        request: Request,
        *,
        stream: bool = False,
        auth: Optional[Union[Auth, Tuple[str, str]]] = None,
        follow_redirects: Optional[bool] = None,
    ) -> Response:
        """Async send a request and return the response."""
        follow = follow_redirects if follow_redirects is not None else self._follow_redirects
        response = await self._send_single_request(request)
        history: List[Response] = []
        redirect_count = 0

        while self._should_follow_redirect(response, request) and follow:
            if redirect_count >= self._max_redirects:
                raise TooManyRedirects(
                    f"Exceeded {self._max_redirects} redirects.", request=request
                )
            history.append(response)
            request = self._build_redirect_request(request, response)
            response = await self._send_single_request(request)
            redirect_count += 1

        response.history = history  # type: ignore[attr-defined]
        if not stream:
            response.read()
        return response

    async def get(self, url: Union[str, URL], **kwargs: Any) -> Response:
        return await self.request("GET", url, **kwargs)

    async def post(self, url: Union[str, URL], **kwargs: Any) -> Response:
        return await self.request("POST", url, **kwargs)

    async def put(self, url: Union[str, URL], **kwargs: Any) -> Response:
        return await self.request("PUT", url, **kwargs)

    async def patch(self, url: Union[str, URL], **kwargs: Any) -> Response:
        return await self.request("PATCH", url, **kwargs)

    async def delete(self, url: Union[str, URL], **kwargs: Any) -> Response:
        return await self.request("DELETE", url, **kwargs)

    async def request(
        self,
        method: str,
        url: Union[str, URL],
        *,
        content: Optional[bytes] = None,
        data: Optional[Any] = None,
        json: Optional[Any] = None,
        params: Optional[Dict] = None,
        headers: Optional[Dict] = None,
        cookies: Optional[Dict] = None,
        auth: Optional[Union[Auth, Tuple[str, str]]] = None,
        follow_redirects: Optional[bool] = None,
        timeout: Optional[Union[float, Timeout]] = None,
        stream: bool = False,
    ) -> Response:
        """Build and send an async HTTP request."""
        request = self._build_request(
            method=method,
            url=url,
            content=content,
            data=data,
            json=json,
            params=params,
            headers=headers,
            cookies=cookies,
        )
        return await self.send(request, stream=stream, auth=auth, follow_redirects=follow_redirects)
