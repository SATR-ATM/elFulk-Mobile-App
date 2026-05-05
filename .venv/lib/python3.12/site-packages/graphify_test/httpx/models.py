"""
httpx models - Request, Response, URL, Headers, Cookies.
"""
from typing import (
    Any, Dict, Iterator, List, Mapping, Optional, Sequence, Tuple, Union
)
import json as json_module
import time

from .exceptions import (
    HTTPStatusError,
    DecodingError,
    StreamConsumed,
    ResponseNotRead,
    RequestNotRead,
    CookieConflict,
)


class URL:
    """
    Represents the URL against which an HTTP request is made.
    """
    def __init__(self, url: Union[str, "URL"] = "", **kwargs: Any) -> None:
        if isinstance(url, URL):
            self._uri_reference = url._uri_reference
        else:
            self._uri_reference = url
        self._params = kwargs

    @property
    def scheme(self) -> str:
        """Return the scheme part of the URL."""
        if "://" in self._uri_reference:
            return self._uri_reference.split("://")[0]
        return ""

    @property
    def host(self) -> str:
        """Return the host part of the URL."""
        parts = self._uri_reference.split("://")
        if len(parts) > 1:
            host_part = parts[1].split("/")[0]
            return host_part.split(":")[0]
        return ""

    @property
    def port(self) -> Optional[int]:
        parts = self._uri_reference.split("://")
        if len(parts) > 1:
            host_part = parts[1].split("/")[0]
            if ":" in host_part:
                return int(host_part.split(":")[1])
        return None

    @property
    def path(self) -> str:
        parts = self._uri_reference.split("://")
        if len(parts) > 1:
            path_part = parts[1].split("/", 1)
            if len(path_part) > 1:
                return "/" + path_part[1].split("?")[0].split("#")[0]
        return "/"

    @property
    def query(self) -> str:
        if "?" in self._uri_reference:
            return self._uri_reference.split("?")[1].split("#")[0]
        return ""

    def copy_with(self, **kwargs: Any) -> "URL":
        return URL(self._uri_reference, **kwargs)

    def __str__(self) -> str:
        return self._uri_reference

    def __repr__(self) -> str:
        return f"URL({self._uri_reference!r})"

    def __eq__(self, other: Any) -> bool:
        return isinstance(other, URL) and str(self) == str(other)


class Headers(Mapping[str, str]):
    """
    HTTP headers, as a case-insensitive, multi-value mapping.
    """
    def __init__(self, headers: Optional[Union[Dict, List[Tuple]]] = None) -> None:
        self._list: List[Tuple[bytes, bytes]] = []
        if isinstance(headers, dict):
            for k, v in headers.items():
                self._list.append((k.lower().encode(), v.encode()))
        elif isinstance(headers, list):
            for k, v in headers:
                self._list.append((k.lower().encode(), v.encode()))

    def get(self, key: str, default: Any = None) -> Any:
        key_lower = key.lower().encode()
        for k, v in self._list:
            if k == key_lower:
                return v.decode()
        return default

    def __getitem__(self, key: str) -> str:
        result = self.get(key)
        if result is None:
            raise KeyError(key)
        return result

    def __iter__(self) -> Iterator[str]:
        return iter(k.decode() for k, _ in self._list)

    def __len__(self) -> int:
        return len(self._list)

    def __repr__(self) -> str:
        items = [(k.decode(), v.decode()) for k, v in self._list]
        return f"Headers({items!r})"


class Cookies(Mapping[str, str]):
    """
    Cookies, as a mutable mapping.
    """
    def __init__(self, cookies: Optional[Dict[str, str]] = None) -> None:
        self._cookies: Dict[Tuple[str, str, str], str] = {}
        if cookies:
            for k, v in cookies.items():
                self.set(k, v)

    def set(self, name: str, value: str, domain: str = "", path: str = "/") -> None:
        self._cookies[(name, domain, path)] = value

    def get(  # type: ignore[override]
        self,
        name: str,
        default: Optional[str] = None,
        domain: Optional[str] = None,
        path: Optional[str] = None,
    ) -> Optional[str]:
        values = [
            v for (n, d, p), v in self._cookies.items()
            if n == name
            and (domain is None or d == domain)
            and (path is None or p == path)
        ]
        if len(values) == 1:
            return values[0]
        elif len(values) > 1:
            from .exceptions import CookieConflict
            raise CookieConflict(
                f"Multiple cookies with name {name!r}",
                request=None  # type: ignore
            )
        return default

    def __getitem__(self, name: str) -> str:
        value = self.get(name)
        if value is None:
            raise KeyError(name)
        return value

    def __iter__(self) -> Iterator[str]:
        return iter(n for (n, _, _) in self._cookies.keys())

    def __len__(self) -> int:
        return len(self._cookies)


class Request:
    """
    The model that represents an HTTP request.
    """
    def __init__(
        self,
        method: str,
        url: Union[str, URL],
        *,
        headers: Optional[Union[Dict, Headers]] = None,
        content: Optional[bytes] = None,
        data: Optional[Any] = None,
        json: Optional[Any] = None,
        stream: Optional[Any] = None,
    ) -> None:
        self.method = method.upper()
        self.url = URL(url) if isinstance(url, str) else url
        self.headers = Headers(headers) if isinstance(headers, dict) else (headers or Headers())
        self._content = content
        self._data = data
        self._json = json
        self.stream = stream

    @property
    def content(self) -> bytes:
        if self._content is None:
            raise RequestNotRead()
        return self._content

    def read(self) -> bytes:
        if self._content is None:
            if self._json is not None:
                self._content = json_module.dumps(self._json).encode()
            elif self._data is not None:
                self._content = str(self._data).encode()
            else:
                self._content = b""
        return self._content

    def __repr__(self) -> str:
        return f"<Request [{self.method}]>"


class Response:
    """
    The model that represents an HTTP response.
    """
    def __init__(
        self,
        status_code: int,
        *,
        headers: Optional[Union[Dict, Headers]] = None,
        content: Optional[bytes] = None,
        stream: Optional[Any] = None,
        request: Optional[Request] = None,
    ) -> None:
        self.status_code = status_code
        self.headers = Headers(headers) if isinstance(headers, dict) else (headers or Headers())
        self._content: Optional[bytes] = content
        self.stream = stream
        self.request = request  # type: ignore
        self._elapsed: Optional[float] = None
        self._num_bytes_downloaded = 0
        self._decoder = None
        self._is_stream_consumed = False

    @property
    def is_informational(self) -> bool:
        return 100 <= self.status_code < 200

    @property
    def is_success(self) -> bool:
        return 200 <= self.status_code < 300

    @property
    def is_redirect(self) -> bool:
        return self.status_code in (301, 302, 303, 307, 308)

    @property
    def is_client_error(self) -> bool:
        return 400 <= self.status_code < 500

    @property
    def is_server_error(self) -> bool:
        return 500 <= self.status_code < 600

    @property
    def is_error(self) -> bool:
        return self.is_client_error or self.is_server_error

    def raise_for_status(self) -> None:
        if self.is_error:
            message = (
                f"{self.status_code} {'Client' if self.is_client_error else 'Server'} Error"
                f" for url: {self.url}"
            )
            raise HTTPStatusError(message, request=self.request, response=self)

    @property
    def url(self) -> URL:
        return self.request.url

    @property
    def content(self) -> bytes:
        if self._content is None:
            raise ResponseNotRead()
        return self._content

    def read(self) -> bytes:
        if self._content is None:
            if self.stream is None:
                self._content = b""
            else:
                if self._is_stream_consumed:
                    raise StreamConsumed()
                self._content = b"".join(self.stream)
                self._is_stream_consumed = True
        return self._content

    def json(self) -> Any:
        try:
            return json_module.loads(self.content)
        except json_module.JSONDecodeError as exc:
            raise DecodingError(str(exc), request=self.request) from exc

    def text(self, encoding: Optional[str] = None) -> str:
        return self.content.decode(encoding or "utf-8")

    @property
    def elapsed(self) -> float:
        if self._elapsed is None:
            raise RuntimeError("elapsed not available until response is complete")
        return self._elapsed

    @property
    def cookies(self) -> Cookies:
        cookies = Cookies()
        set_cookie = self.headers.get("set-cookie", "")
        if set_cookie:
            parts = set_cookie.split(";")
            if parts and "=" in parts[0]:
                k, v = parts[0].split("=", 1)
                cookies.set(k.strip(), v.strip())
        return cookies

    def __repr__(self) -> str:
        return f"<Response [{self.status_code}]>"
