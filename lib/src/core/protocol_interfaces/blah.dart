import "../../../core.dart";

sealed class DiscoveryCallbackParameter {
  Uri get uri;
}

final class UriDiscoveryCallbackParameter {
  UriDiscoveryCallbackParameter(this.uri);

  final Uri uri;
}

final class FormDiscoveryCallbackParameter {
  FormDiscoveryCallbackParameter(this.form);

  final AugmentedForm form;

  Uri get uri => form.href;
}
