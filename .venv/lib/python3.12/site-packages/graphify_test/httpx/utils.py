"""
httpx utils - internal utility functions used across the library.
"""
import codecs
import re
import time
from contextlib import contextmanager
from typing import Any, Dict, Generator, Iterable, Iterator, List, Optional, Tuple, Union
from urllib.parse import urlencode, urljoin, urlparse, quote, unquote

from .exceptions import InvalidURL


# Primitive types that can be serialized to query string params
PrimitiveData = Optional[Union[str, int, float, bool]]


def primitive_value_to_str(value: PrimitiveData) -> str:
    """Convert a primitive value to its string representation."""
    if value is True:
        return "true"
    elif value is False:
        return "false"
    elif value is None:
        return ""
    return str(value)


def normalize_header_key(value: str, encoding: Optional[str] = None) -> bytes:
    """Normalize a header key to bytes."""
    if isinstance(value, bytes):
        return value.lower()
    return value.lower().encode(encoding or "latin-1")


def normalize_header_value(value: str, encoding: Optional[str] = None) -> bytes:
    """Normalize a header value to bytes."""
    if isinstance(value, bytes):
        return value
    return value.encode(encoding or "latin-1")


def to_bytes(value: Union[str, bytes], encoding: str = "utf-8") -> bytes:
    """Convert a string or bytes to bytes."""
    if isinstance(value, bytes):
        return value
    return value.encode(encoding)


def to_str(value: Union[str, bytes], encoding: str = "utf-8") -> str:
    """Convert bytes or str to str."""
    if isinstance(value, str):
        return value
    return value.decode(encoding)


def to_bytes_or_str(value: Union[str, bytes], match_type_of: Union[str, bytes]) -> Union[str, bytes]:
    """Convert value to match the type of match_type_of."""
    if isinstance(match_type_of, bytes):
        return to_bytes(value)
    return to_str(value)


def unset_all_cookies(response: Any) -> None:
    """Clear all cookies from a response."""
    from .models import Cookies
    response._cookies = Cookies()


def flatten_queryparams(
    params: Union[
        Dict[str, Union[PrimitiveData, Iterable[PrimitiveData]]],
        List[Tuple[str, PrimitiveData]],
        None,
    ]
) -> List[Tuple[str, str]]:
    """Flatten query params into a list of (key, value) tuples."""
    if params is None:
        return []
    if isinstance(params, list):
        return [(k, primitive_value_to_str(v)) for k, v in params]
    result = []
    for k, v in params.items():
        if isinstance(v, (list, tuple)):
            for item in v:
                result.append((k, primitive_value_to_str(item)))
        else:
            result.append((k, primitive_value_to_str(v)))
    return result


def parse_content_type(header: str) -> Tuple[str, Dict[str, str]]:
    """
    Parse a Content-Type header into media type and parameters.
    e.g. "application/json; charset=utf-8" -> ("application/json", {"charset": "utf-8"})
    """
    parts = header.split(";")
    media_type = parts[0].strip().lower()
    params: Dict[str, str] = {}
    for part in parts[1:]:
        part = part.strip()
        if "=" in part:
            key, _, value = part.partition("=")
            params[key.strip().lower()] = value.strip().strip('"')
    return media_type, params


def get_ca_bundle_from_env() -> Optional[str]:
    """Get SSL CA bundle path from environment variables."""
    import os
    for env_var in ("REQUESTS_CA_BUNDLE", "CURL_CA_BUNDLE", "SSL_CERT_FILE"):
        val = os.environ.get(env_var)
        if val:
            return val
    return None


def guess_json_utf(data: bytes) -> Optional[str]:
    """
    Detect the encoding of a JSON byte string by inspecting BOM and null bytes.
    Based on RFC 4627 section 3.
    """
    if data[:3] == b"\xef\xbb\xbf":
        return "utf-8-sig"
    if data[:4] in (b"\x00\x00\xfe\xff", b"\xff\xfe\x00\x00"):
        return "utf-32"
    if data[:2] in (b"\xfe\xff", b"\xff\xfe"):
        return "utf-16"
    # Check for null bytes to distinguish UTF-32 / UTF-16 / UTF-8
    null_count = data[:4].count(b"\x00")
    if null_count == 3:
        return "utf-32"
    if null_count == 2:
        return "utf-16"
    return "utf-8"


def is_known_encoding(encoding: str) -> bool:
    """Return True if the encoding string is a valid Python codec."""
    try:
        codecs.lookup(encoding)
        return True
    except LookupError:
        return False


def format_request_url(url: str, params: Optional[Dict] = None) -> str:
    """Format a URL with optional query parameters."""
    parsed = urlparse(url)
    if params:
        flat = flatten_queryparams(params)
        query = urlencode(flat)
        # Preserve existing query if any
        if parsed.query:
            query = parsed.query + "&" + query
        url = url.split("?")[0] + "?" + query
    return url


def parse_scheme(url: str) -> str:
    """Extract and validate the scheme from a URL."""
    match = re.match(r"^([a-zA-Z][a-zA-Z0-9+\-.]*):.*", url)
    if not match:
        raise InvalidURL(f"No scheme included in URL {url!r}")
    return match.group(1).lower()


def elapsed_time(start: float) -> float:
    """Return elapsed time in seconds since start."""
    return time.time() - start


@contextmanager
def timer() -> Generator[Dict[str, float], None, None]:
    """Context manager to measure elapsed time."""
    result: Dict[str, float] = {}
    start = time.time()
    try:
        yield result
    finally:
        result["elapsed"] = elapsed_time(start)


def obfuscate_sensitive_headers(headers: Dict[str, str]) -> Dict[str, str]:
    """
    Obfuscate sensitive header values for logging purposes.
    Replaces Authorization and Cookie values with '[REDACTED]'.
    """
    sensitive = {"authorization", "cookie", "set-cookie", "proxy-authorization"}
    return {
        k: "[REDACTED]" if k.lower() in sensitive else v
        for k, v in headers.items()
    }


def get_environment_proxies() -> Dict[str, str]:
    """Read proxy settings from environment variables."""
    import os
    proxies = {}
    for scheme in ("http", "https", "all"):
        for env_var in (f"{scheme}_proxy", f"{scheme.upper()}_PROXY"):
            proxy = os.environ.get(env_var)
            if proxy:
                proxies[f"{scheme}://"] = proxy
                break
    return proxies


def same_origin(url1: "URL", url2: "URL") -> bool:  # type: ignore[name-defined]
    """Return True if two URLs have the same origin (scheme + host + port)."""
    return (
        url1.scheme == url2.scheme
        and url1.host == url2.host
        and url1.port == url2.port
    )


def should_not_be_proxied(url: "URL", no_proxy: Optional[str] = None) -> bool:  # type: ignore[name-defined]
    """Determine if the URL should bypass the proxy based on NO_PROXY setting."""
    import os
    no_proxy = no_proxy or os.environ.get("NO_PROXY", "")
    if not no_proxy:
        return False
    host = url.host
    for pattern in no_proxy.split(","):
        pattern = pattern.strip()
        if not pattern:
            continue
        if host == pattern or host.endswith("." + pattern):
            return True
    return False
