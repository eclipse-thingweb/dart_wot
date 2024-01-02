import "../definitions/form.dart";
import "../definitions/operation_type.dart";

const _getString = "GET";
const _putString = "PUT";
const _postString = "POST";
const _deleteString = "DELETE";
const _patchString = "PATCH";

/// Defines the available HTTP request methods.
enum HttpRequestMethod {
  /// Corresponds with the GET request method.
  get(_getString),

  /// Corresponds with the PUT request method.
  put(_putString),

  /// Corresponds with the POST request method.
  post(_postString),

  /// Corresponds with the DELETE request method.
  delete(_deleteString),

  /// Corresponds with the PATCH request method.
  patch(_patchString);

  /// Constructor
  const HttpRequestMethod(this.methodName);

  /// The string representation of this method.
  final String methodName;

  static HttpRequestMethod? _requestMethodFromString(String formDefinition) {
    switch (formDefinition) {
      case _getString:
        return get;
      case _putString:
        return put;
      case _postString:
        return post;
      case _deleteString:
        return delete;
      case _patchString:
        return patch;
      default:
        return null;
    }
  }

  static HttpRequestMethod _requestMethodFromOperationType(
    OperationType operationType,
  ) {
    // TODO(JKRhb): Handle observe/subscribe case
    switch (operationType) {
      case OperationType.readproperty:
      case OperationType.readmultipleproperties:
      case OperationType.readallproperties:
        return HttpRequestMethod.get;
      case OperationType.writeproperty:
      case OperationType.writemultipleproperties:
        return HttpRequestMethod.put;
      case OperationType.invokeaction:
        return HttpRequestMethod.post;
      default:
        throw UnimplementedError();
    }
  }

  /// Determine the appropriate [HttpRequestMethod] by [form] or
  /// [operationType].
  static HttpRequestMethod getRequestMethod(
    Form form,
    OperationType operationType,
  ) {
    final dynamic formDefinition = form.additionalFields["htv:methodName"];
    if (formDefinition is String) {
      final requestMethod = _requestMethodFromString(formDefinition);
      if (requestMethod != null) {
        return requestMethod;
      }
    }

    return _requestMethodFromOperationType(operationType);
  }
}
