import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/global/app.dart';
import 'package:mrt_wallet/app/http/models/auth.dart';
import 'package:mrt_wallet/app/utils/utils.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/api/services/models/models/auth.dart';

class HTTPServiceProviderFields extends StatefulWidget {
  const HTTPServiceProviderFields(
      {this.error,
      this.exclude = const [],
      super.key,
      this.initialUrl,
      this.hint,
      this.enableAuth = true});
  final String? error;
  final List<String> exclude;
  final RPCURL? initialUrl;
  final String? hint;
  final bool enableAuth;

  @override
  State<HTTPServiceProviderFields> createState() =>
      HTTPServiceProviderFieldsState();
}

class HTTPServiceProviderFieldsState extends State<HTTPServiceProviderFields>
    with SafeState {
  String? error;
  bool useAuthenticated = false;
  ProviderAuthType auth = ProviderAuthType.header;

  void onChangeAuthMode(ProviderAuthType? auth) {
    this.auth = auth ?? this.auth;
    updateState();
  }

  void onChangeAuthenticated(bool? v) {
    useAuthenticated = !useAuthenticated;
    updateState();
  }

  String authKey = "";
  String authValue = "";

  String get authKeyLabe {
    return auth.isDigest ? "username".tr : "authenticated_key".tr;
  }

  String get authValueLabe {
    return auth.isDigest ? "password".tr : "authenticated_value".tr;
  }

  String get authKeyExample {
    switch (auth) {
      case ProviderAuthType.digest:
        return "username".tr;
      default:
        return "example_value".tr.replaceOne(auth.isHeader
            ? APPConst.exampleAuthenticatedHeader
            : APPConst.exampleAuthenticatedQuery);
    }
  }

  String get authValueExample {
    switch (auth) {
      case ProviderAuthType.digest:
        return "password".tr;
      default:
        return "example_value".tr.replaceOne(auth.isHeader
            ? APPConst.exampleAuthenticatedHeaderValue
            : APPConst.exampleBase58);
    }
  }

  // hint:
  void onChangeKey(String v) {
    authKey = v;
  }

  void onChangeValue(String v) {
    authValue = v;
  }

  String? validateKey(String? v) {
    if (v?.trim().isEmpty ?? true) {
      return "authenticated_key_validator".tr;
    }
    if (v!.length > APPConst.maximumHeaderValue) {
      return "value_is_to_large".tr;
    }
    return null;
  }

  String? validateValue(String? v) {
    if (v?.trim().isEmpty ?? true) {
      return "authenticated_value_validator".tr;
    }
    if (v!.length > APPConst.maximumHeaderValue) {
      return "value_is_to_large".tr;
    }
    return null;
  }

  String rpcURL = '';

  void onChageUrl(String v) {
    rpcURL = v;
  }

  String? validateRpcUrl(String? v) {
    final path =
        StrUtils.validateUri(v, schame: ['http', 'https', 'wss', 'ws']);
    if (path == null) return "rpc_url_validator".tr;
    if (widget.exclude.contains(path)) {
      return "rpc_url_already_exists".tr;
    }
    return null;
  }

  GlobalKey<FormState> formKey =
      GlobalKey(debugLabel: "HTTPServiceProviderFieldsState_formstate");

  RPCURL? getEndpoint() {
    if (!(formKey.currentState?.validate() ?? false)) return null;
    ProviderAuthenticated? authenticated;
    if (useAuthenticated) {
      if (auth.isDigest) {
        authenticated =
            DigestProviderAuthenticated(password: authKey, username: authValue);
      } else {
        authenticated = BasicProviderAuthenticated(
            type: auth, key: authKey, value: authValue);
      }
    }
    return RPCURL(url: rpcURL, auth: authenticated);
  }

  void initialUrl() {
    final initialUrl = widget.initialUrl;
    if (initialUrl != null) {
      rpcURL = initialUrl.url;
      if (widget.enableAuth && initialUrl.auth != null) {
        useAuthenticated = true;
        final auth = initialUrl.auth!;
        this.auth = auth.type;
        switch (auth.type) {
          case ProviderAuthType.header:
          case ProviderAuthType.query:
            final basicAuth = auth.cast<BasicProviderAuthenticated>();
            authKey = basicAuth.key;
            authValue = basicAuth.value;
            break;
          case ProviderAuthType.digest:
            final basicAuth = auth.cast<DigestProviderAuthenticated>();
            authKey = basicAuth.username;
            authValue = basicAuth.password;
            break;
        }
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initialUrl();
  }

  @override
  void didUpdateWidget(covariant HTTPServiceProviderFields oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget != widget) {
      initialUrl();
      updateState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          AppTextField(
            label: "endpoint_url".tr,
            pasteIcon: true,
            prefixIcon: const Icon(Icons.link),
            validator: validateRpcUrl,
            onChanged: onChageUrl,
            error: error,
            initialValue: rpcURL,
            maxLines: 2,
            minlines: 1,
            hint: widget.hint,
          ),
          // WidgetConstant.height20,
          if (widget.enableAuth)
            AppSwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text("authenticated".tr),
              subtitle: Text("add_provider_authenticated".tr),
              value: useAuthenticated,
              onChanged: onChangeAuthenticated,
            ),
          APPAnimatedSize(
              isActive: useAuthenticated,
              onActive: (c) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WidgetConstant.height8,
                      AppDropDownBottom(
                        items: {
                          for (final i in ProviderAuthType.values)
                            i: Text(i.name.camelCase)
                        },
                        hint: "authenticated_type".tr,
                        onChanged: onChangeAuthMode,
                        value: auth,
                      ),
                      WidgetConstant.height20,
                      AppTextField(
                        label: authKeyLabe,
                        pasteIcon: true,
                        initialValue: authKey,
                        hint: authKeyExample,
                        onChanged: onChangeKey,
                        validator: validateKey,
                      ),
                      AppTextField(
                          pasteIcon: true,
                          label: authValueLabe,
                          initialValue: authValue,
                          hint: authValueExample,
                          onChanged: onChangeValue,
                          validator: validateValue),
                    ],
                  ),
              onDeactive: (c) => WidgetConstant.sizedBox),
        ],
      ),
    );
  }
}
