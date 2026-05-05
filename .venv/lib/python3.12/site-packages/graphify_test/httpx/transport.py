"""
httpx transport - low-level transport layer for sending HTTP requests.
Defines the Transport interface and a mock transport for testing.
"""
import socket
import ssl
import time
from abc import ABC, abstractmethod
from typing import Any, AsyncIterator, Dict, Iterator, List, Optional, Tuple, Union

from .models import Request, Response, Headers
from .exceptions import (
    ConnectError,
    ConnectTimeout,
    ReadTimeout,
    WriteTimeout,
    PoolTimeout,
    ProxyError,
    NetworkError,
)
from .utils import timer


class BaseTransport(ABC):
    """
    Abstract base class for all transports.
    A transport is responsible for taking a Request object and returning
    a Response. It handles the actual network I/O.
    """
    @abstractmethod
    def handle_request(self, request: Request) -> Response:
        raise NotImplementedError

    def close(self) -> None:
        pass

    def __enter__(self) -> "BaseTransport":
        return self

    def __exit__(self, *args: Any) -> None:
        self.close()


class AsyncBaseTransport(ABC):
    """
    Abstract base class for async transports.
    """
    @abstractmethod
    async def handle_async_request(self, request: Request) -> Response:
        raise NotImplementedError

    async def aclose(self) -> None:
        pass

    async def __aenter__(self) -> "AsyncBaseTransport":
        return self

    async def __aexit__(self, *args: Any) -> None:
        await self.aclose()


class ConnectionPool:
    """
    Manages a pool of HTTP connections to reduce connection overhead.
    Connections are keyed by (scheme, host, port).
    """
    def __init__(
        self,
        max_connections: int = 100,
        max_keepalive_connections: int = 20,
        keepalive_expiry: float = 5.0,
    ) -> None:
        self._max_connections = max_connections
        self._max_keepalive = max_keepalive_connections
        self._keepalive_expiry = keepalive_expiry
        self._connections: Dict[Tuple[str, str, int], List[Any]] = {}
        self._active_count = 0

    def _connection_key(self, request: Request) -> Tuple[str, str, int]:
        url = request.url
        port = url.port or (443 if url.scheme == "https" else 80)
        return (url.scheme, url.host, port)

    def acquire(self, request: Request) -> Optional[Any]:
        """Acquire a connection from the pool, or return None if none available."""
        key = self._connection_key(request)
        connections = self._connections.get(key, [])
        # Filter out expired connections
        now = time.time()
        alive = [c for c in connections if now - c.get("last_used", 0) < self._keepalive_expiry]
        self._connections[key] = alive
        if alive:
            conn = alive.pop()
            self._active_count += 1
            return conn
        return None

    def release(self, request: Request, connection: Any) -> None:
        """Return a connection to the pool after use."""
        key = self._connection_key(request)
        connection["last_used"] = time.time()
        if self._connections.get(key) is None:
            self._connections[key] = []
        if len(self._connections[key]) < self._max_keepalive:
            self._connections[key].append(connection)
        self._active_count = max(0, self._active_count - 1)

    def close(self) -> None:
        """Close all connections in the pool."""
        self._connections.clear()
        self._active_count = 0

    @property
    def active_count(self) -> int:
        return self._active_count


class HTTPTransport(BaseTransport):
    """
    Default sync HTTP transport using urllib3 / raw sockets.
    Wraps a ConnectionPool for connection reuse.
    """
    def __init__(
        self,
        verify: Union[bool, str] = True,
        cert: Optional[Union[str, Tuple[str, str]]] = None,
        http1: bool = True,
        http2: bool = False,
        limits: Optional[Any] = None,
        proxy: Optional[str] = None,
        uds: Optional[str] = None,
        local_address: Optional[str] = None,
        retries: int = 0,
    ) -> None:
        self._verify = verify
        self._cert = cert
        self._http1 = http1
        self._http2 = http2
        self._proxy = proxy
        self._retries = retries
        max_conn = getattr(limits, "max_connections", 100) if limits else 100
        max_keepalive = getattr(limits, "max_keepalive_connections", 20) if limits else 20
        keepalive_expiry = getattr(limits, "keepalive_expiry", 5.0) if limits else 5.0
        self._pool = ConnectionPool(
            max_connections=max_conn,
            max_keepalive_connections=max_keepalive,
            keepalive_expiry=keepalive_expiry,
        )

    def handle_request(self, request: Request) -> Response:
        """
        Send the request and return a Response.
        This is a simplified implementation for illustration.
        """
        connection = self._pool.acquire(request)
        if connection is None:
            connection = self._create_connection(request)

        try:
            with timer() as t:
                response = self._send_request(request, connection)
            response._elapsed = t["elapsed"]
        except ConnectTimeout:
            raise
        except socket.timeout as exc:
            raise ReadTimeout(str(exc), request=request) from exc
        except OSError as exc:
            raise ConnectError(str(exc), request=request) from exc
        finally:
            self._pool.release(request, connection)

        return response

    def _create_connection(self, request: Request) -> Dict[str, Any]:
        """Create a new connection dict (stub implementation)."""
        return {"created_at": time.time(), "last_used": time.time()}

    def _send_request(self, request: Request, connection: Dict[str, Any]) -> Response:
        """Send the request on the connection (stub - real impl uses urllib3)."""
        # Stub: return a 200 response
        return Response(
            status_code=200,
            headers=Headers({"content-type": "application/json"}),
            content=b'{"status": "ok"}',
            request=request,
        )

    def close(self) -> None:
        self._pool.close()


class AsyncHTTPTransport(AsyncBaseTransport):
    """
    Async HTTP transport using httpcore or trio/asyncio sockets.
    """
    def __init__(
        self,
        verify: Union[bool, str] = True,
        cert: Optional[Union[str, Tuple[str, str]]] = None,
        http1: bool = True,
        http2: bool = False,
        limits: Optional[Any] = None,
        proxy: Optional[str] = None,
    ) -> None:
        self._verify = verify
        self._cert = cert
        self._http1 = http1
        self._http2 = http2
        self._proxy = proxy
        self._pool: Optional[ConnectionPool] = None

    async def handle_async_request(self, request: Request) -> Response:
        """Send request asynchronously and return response."""
        # In a real implementation this would use asyncio/trio sockets
        return Response(
            status_code=200,
            headers=Headers({"content-type": "application/json"}),
            content=b'{"status": "ok"}',
            request=request,
        )

    async def aclose(self) -> None:
        if self._pool:
            self._pool.close()


class MockTransport(BaseTransport):
    """
    A mock transport for testing that returns preconfigured responses.
    """
    def __init__(
        self,
        handler: Optional[Any] = None,
        responses: Optional[List[Response]] = None,
    ) -> None:
        self._handler = handler
        self._responses = list(responses or [])
        self._request_history: List[Request] = []

    def handle_request(self, request: Request) -> Response:
        self._request_history.append(request)
        if self._handler is not None:
            return self._handler(request)
        if self._responses:
            return self._responses.pop(0)
        return Response(
            status_code=200,
            headers=Headers({"content-type": "application/json"}),
            content=b'{}',
            request=request,
        )

    @property
    def request_history(self) -> List[Request]:
        return self._request_history


class ProxyTransport(BaseTransport):
    """
    Transport that routes requests through an HTTP/HTTPS proxy.
    Wraps another transport and prepends proxy handling.
    """
    def __init__(
        self,
        proxy_url: str,
        *,
        proxy_headers: Optional[Dict[str, str]] = None,
        verify: Union[bool, str] = True,
        cert: Optional[Any] = None,
        limits: Optional[Any] = None,
        transport: Optional[BaseTransport] = None,
    ) -> None:
        self._proxy_url = proxy_url
        self._proxy_headers = Headers(proxy_headers or {})
        self._transport = transport or HTTPTransport(verify=verify, cert=cert, limits=limits)

    def handle_request(self, request: Request) -> Response:
        """Route request through proxy."""
        proxy_request = Request(
            method="CONNECT" if request.url.scheme == "https" else request.method,
            url=self._proxy_url,
            headers=dict(self._proxy_headers),
        )
        try:
            proxy_response = self._transport.handle_request(proxy_request)
        except TransportError as exc:
            raise ProxyError(str(exc), request=request) from exc

        if request.url.scheme == "https":
            # After CONNECT tunnel is established, send the real request
            return self._transport.handle_request(request)
        return proxy_response

    def close(self) -> None:
        self._transport.close()


# Re-export for convenience
from .exceptions import TransportError
