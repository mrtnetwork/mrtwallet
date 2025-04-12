import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/wallet/network/ripple/account/state.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:xrpl_dart/xrpl_dart.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

class RippleSelectTokenView extends StatefulWidget {
  const RippleSelectTokenView({
    super.key,
    required this.account,
    required this.scrollController,
  });
  final RippleChain account;
  final ScrollController scrollController;

  @override
  State<RippleSelectTokenView> createState() =>
      _BuildRippleCurrencyAmountViewState();
}

class _BuildRippleCurrencyAmountViewState
    extends RippleAccountState<RippleSelectTokenView>
    with SingleTickerProviderStateMixin, ProgressMixin {
  late final TabController controller = TabController(length: 2, vsync: this);
  @override
  RippleChain get account => widget.account;

  void _listener() {
    _isReady();
  }

  @override
  void onInitOnce() {
    controller.addListener(_listener);
    MethodUtils.after(() async {
      _isReady();
    });
    super.onInitOnce();
  }

  @override
  void safeDispose() {
    controller.removeListener(_listener);
    controller.dispose();
    super.safeDispose();
  }

  ReceiptAddress<XRPAddress>? issuer;
  String? currency;
  bool isReady = false;

  void onSelectIssuer(ReceiptAddress<XRPAddress>? issue) {
    issuer = issue;
    _isReady();
  }

  void setCurrency(String? newCurrency) {
    currency = newCurrency;
    _isReady();
  }

  void _isReady() {
    isReady = issuer != null && currency != null;
    updateState();
  }

  void onSetupAccountAsset(RippleIssueToken token) {
    context.pop(XRPPickedAssets.account(token));
  }

  void onSetupCreate() {
    if (!isReady) return;
    final XRPIssueToken token = XRPIssueToken(
        balance: "0", issuer: issuer!.networkAddress, symbol: currency!);
    context.pop(XRPPickedAssets.create(token));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialPageView(
      child: NestedScrollView(
        controller: widget.scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            title: Text("choose_payment_currency".tr),
            bottom: TabBar(
              controller: controller,
              tabs: [
                Tab(text: "account_tokens".tr),
                Tab(text: "create_tokens".tr),
              ],
            ),
          )
        ],
        body: Builder(builder: (context) {
          return ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
                scrollbars: false, physics: const ClampingScrollPhysics()),
            child: TabBarView(controller: controller, children: [
              _FromAccountToken(
                  scrollController: widget.scrollController, state: this),
              _SetupNewToken(
                  scrollController: widget.scrollController, state: this),
            ]),
          );
        }),
      ),
    );
  }
}

class ReadOnlyTabbar extends StatelessWidget implements PreferredSizeWidget {
  const ReadOnlyTabbar(
      {required this.child, required this.isEnabled, super.key});
  final bool isEnabled;
  final PreferredSizeWidget child;
  @override
  Size get preferredSize => child.preferredSize;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !isEnabled,
      child: child,
    );
  }
}

class _SetupNewToken extends StatelessWidget {
  const _SetupNewToken({required this.scrollController, required this.state});
  final ScrollController scrollController;
  final _BuildRippleCurrencyAmountViewState state;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverConstraintsBoxView(
          padding: WidgetConstant.paddingHorizontal20,
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WidgetConstant.height20,
                PageTitleSubtitle(
                    title: "create_token".tr,
                    body: Text("xrp_create_token_desc".tr)),
                ReceiptAddressView(
                  address: state.issuer,
                  title: "issuer",
                  subtitle: "token_issuer".tr,
                  onTap: () {
                    context
                        .openSliverBottomSheet<ReceiptAddress<XRPAddress>>(
                            "token_amount".tr,
                            bodyBuilder: (c) =>
                                SelectRecipientAccountView<XRPAddress>(
                                  account: state.account,
                                  scrollController: c,
                                  subtitle: PageTitleSubtitle(
                                      title: "issuer".tr,
                                      body: Text("token_issuer".tr)),
                                ))
                        .then(state.onSelectIssuer);
                  },
                ),
                WidgetConstant.height20,
                Text("currency".tr, style: context.textTheme.titleMedium),
                Text("token_currency".tr),
                WidgetConstant.height8,
                ContainerWithBorder(
                  onRemove: () {
                    context
                        .openSliverBottomSheet<String>(
                          "token_amount".tr,
                          child: StringWriterView(
                            defaultValue: state.currency,
                            regExp: RippleConst.currencyCodeRegex,
                            minLines: 1,
                            title: PageTitleSubtitle(
                                title: "currency".tr,
                                body: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("token_currency".tr),
                                  ],
                                )),
                            buttonText: "setup_input".tr,
                            label: "currency".tr,
                          ),
                        )
                        .then(state.setCurrency);
                  },
                  onRemoveIcon: state.currency != null
                      ? const Icon(Icons.edit)
                      : const Icon(Icons.add),
                  validate: state.currency != null,
                  child:
                      Text(state.currency ?? "tap_to_enter_currency_code".tr),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FixedElevatedButton(
                      padding: WidgetConstant.paddingVertical40,
                      onPressed: state.isReady ? state.onSetupCreate : null,
                      child: Text("setup_currency_amount".tr),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FromAccountToken extends StatefulWidget {
  const _FromAccountToken(
      {required this.scrollController, required this.state});
  final ScrollController scrollController;
  final _BuildRippleCurrencyAmountViewState state;

  @override
  State<_FromAccountToken> createState() => _FromAccountTokenState();
}

class _FromAccountTokenState extends State<_FromAccountToken>
    with SafeState, ProgressMixin, AutomaticKeepAliveClientMixin {
  List<RippleIssueToken> accountToken = [];
  List<RippleIssueToken> fetchedTokens = [];
  List<RippleIssueToken> tokens = [];
  Future<void> getAccountTokens() async {
    final r = await MethodUtils.call(() async {
      return await widget.state.client.accountTokens(widget.state.address);
    });
    if (r.hasError) {
      progressKey.errorText(r.error!.tr, backToIdle: false);
      return;
    }
    fetchedTokens = r.result;
    final issuers = accountToken.map((e) => e.issuer);
    tokens = [
      ...fetchedTokens.where((e) => !issuers.contains(e.issuer)),
      ...accountToken
    ];
    progressKey.success();
  }

  @override
  void onInitOnce() {
    MethodUtils.after(() async {
      accountToken.addAll(widget.state.address.tokens);
      getAccountTokens();
    });
    super.onInitOnce();
  }

  @override
  void safeDispose() {
    for (final i in fetchedTokens) {
      i.balance.dispose();
    }
    super.safeDispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PageProgress(
      key: progressKey,
      initialWidget:
          ProgressWithTextView(text: "fetching_account_token_please_wait".tr),
      initialStatus: StreamWidgetStatus.progress,
      backToIdle: APPConst.oneSecoundDuration,
      child: (context) => ConditionalWidgets(enable: tokens.isEmpty, widgets: {
        true: (context) => NoItemFoundWidget(),
        false: (context) =>
            CustomScrollView(controller: widget.scrollController, slivers: [
              SliverConstraintsBoxView(
                padding: WidgetConstant.paddingHorizontal20,
                sliver: SliverList.separated(
                    itemCount: tokens.length,
                    itemBuilder: (context, index) {
                      final token = tokens[index];
                      return TokenDetailsView(
                        token: token,
                        onSelect: () => widget.state.onSetupAccountAsset(token),
                        onSelectIcon: WidgetConstant.sizedBox,
                      );
                    },
                    separatorBuilder: (context, index) =>
                        WidgetConstant.sizedBox),
              ),
            ])
      }),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
