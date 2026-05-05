"""
httpx exceptions - core exception hierarchy for the HTTP client library.
"""
from typing import Optional, Any


class HTTPStatusError(Exception):
    """
    Raised by ``response.raise_for_status()``
    Includes the original request and response on the exception.
    """
    def __init__(self, message: str, *, request: "Request", response: "Response") -> None:
        super().__init__(message)
        self.request = request
        self.response = response


class RequestError(Exception):
    """
    Base class for all request errors. Raised whenever a request cannot
    be sent, or a response cannot be received.
    """
    def __init__(self, message: str, *, request: Optional["Request"] = None) -> None:
        super().__init__(message)
        self._request: Optional["Request"] = request

    @property
    def request(self) -> "Request":
        if self._request is None:
            raise RuntimeError("request is not set")
        return self._request

    @request.setter
    def request(self, request: "Request") -> None:
        self._request = request


class TransportError(RequestError):
    """Base class for transport-layer errors."""
    pass


class TimeoutException(TransportError):
    """Base class for timeout errors."""
    pass


class ConnectTimeout(TimeoutException):
    """Timed out while connecting to the host."""
    pass


class ReadTimeout(TimeoutException):
    """Timed out while receiving data from the host."""
    pass


class WriteTimeout(TimeoutException):
    """Timed out while sending data to the host."""
    pass


class PoolTimeout(TimeoutException):
    """Timed out waiting to acquire a connection from the pool."""
    pass


class NetworkError(TransportError):
    """Failed to make a network connection, or lost an existing connection."""
    pass


class ConnectError(NetworkError):
    """Failed to establish a connection."""
    pass


class ReadError(NetworkError):
    """Failed to receive data from the network."""
    pass


class WriteError(NetworkError):
    """Failed to send data through the network."""
    pass


class CloseError(NetworkError):
    """Failed to close a connection."""
    pass


class ProxyError(TransportError):
    """An error occurred while establishing a proxy connection."""
    pass


class UnsupportedProtocol(TransportError):
    """Attempted to make a request to an unsupported protocol."""
    pass


class DecodingError(RequestError):
    """Decoding of the response failed, due to a malformed encoding."""
    pass


class TooManyRedirects(RequestError):
    """Too many redirects."""
    pass


class InvalidURL(RequestError):
    """URL is improperly formed or cannot be parsed."""
    pass


class CookieConflict(RequestError):
    """
    Attempted to lookup a cookie by name, but multiple cookies existed.
    Can be resolved by using the response.cookies.get(name, domain=..., path=...).
    """
    pass


class StreamError(RequestError):
    """
    The developer made an error in accessing the request/response stream in
    an improper way.
    """
    pass


class StreamConsumed(StreamError):
    """
    Attempted to read or stream content, but the content has already been streamed.
    """
    pass


class StreamNotRead(StreamError):
    """
    Attempted to access streaming response content, without having called read().
    """
    pass


class ResponseNotRead(StreamNotRead):
    """Attempted to access the response content, without having called read()."""
    pass


class RequestNotRead(StreamNotRead):
    """Attempted to access the request content, without having called read()."""
    pass
