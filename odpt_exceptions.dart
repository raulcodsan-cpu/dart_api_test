/// Base exception class for all ODPT API errors.
abstract class OdptApiException implements Exception {
  final String message;
  final int statusCode;

  const OdptApiException(this.message, this.statusCode);

  @override
  String toString() => 'OdptApiException (HTTP $statusCode): $message';
}

/// HTTP 400: Invalid query parameters or bad request.
class OdptBadRequestException extends OdptApiException {
  const OdptBadRequestException([
    String message = 'Invalid parameter(s) specified.',
  ]) : super(message, 400);
}

/// HTTP 401: Invalid or missing acl:consumerKey.
class OdptUnauthorizedException extends OdptApiException {
  const OdptUnauthorizedException([
    String message = 'Incorrect or invalid acl:consumerKey.',
  ]) : super(message, 401);
}

/// HTTP 403: Consumer key does not have permission for the requested resource.
class OdptForbiddenException extends OdptApiException {
  const OdptForbiddenException([
    String message = 'Access denied. No permission for this resource.',
  ]) : super(message, 403);
}

/// HTTP 404: Resource or endpoint not found.
class OdptNotFoundException extends OdptApiException {
  const OdptNotFoundException([String message = 'No matching data found.'])
    : super(message, 404);
}

/// HTTP 500: Internal server error on the ODPT backend.
class OdptInternalServerErrorException extends OdptApiException {
  const OdptInternalServerErrorException([
    String message = 'ODPT internal server error.',
  ]) : super(message, 500);
}

/// HTTP 503: Service temporarily unavailable or rate limited.
class OdptServiceUnavailableException extends OdptApiException {
  const OdptServiceUnavailableException([
    String message = 'ODPT service is temporarily unavailable.',
  ]) : super(message, 503);
}

/// Catch-all for other non-200 HTTP status codes.
class OdptHttpException extends OdptApiException {
  OdptHttpException(
    int statusCode, [
    String message = 'Unexpected HTTP error occurred.',
  ]) : super(message, statusCode);
}
