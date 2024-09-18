import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/network/bch/token/pages/cash_token_info.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/crypto/utils/bitcoin/bitcoin.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class TransactionOrderingView extends StatefulWidget {
  const TransactionOrderingView({
    super.key,
    required this.inputs,
    required this.outputs,
    required this.network,
  });
  final List<UtxoWithAddress> inputs;
  final List<BitcoinBaseOutput> outputs;
  final WalletBitcoinNetwork network;

  @override
  State<TransactionOrderingView> createState() =>
      _TransactionOrderingViewState();
}

class _TransactionOrderingViewState extends State<TransactionOrderingView> {
  late final List<_OutputWithKey> outputs = widget.outputs
      .where((element) => element is! BitcoinBurnableOutput)
      .map((e) => _OutputWithKey._(e, widget.network))
      .toList();
  late final List<_InputsWithKey> inputs =
      widget.inputs.map((e) => _InputsWithKey(item: e)).toList();

  void ordering() {
    final orderedInputs = inputs.map((e) => e.item).toList();
    final List<BitcoinBaseOutput> orderedOutputs = [
      ...outputs.map((e) => e.output).toList(),
      ...widget.outputs.whereType<BitcoinBurnableOutput>().toList()
    ];
    context.pop((orderedInputs, orderedOutputs));
  }

  void onUpdate() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Expanded(child: Text("transaction_ordering".tr)),
              FilledButton.icon(
                onPressed: ordering,
                label: Text("save".tr),
                icon: const Icon(Icons.save),
              )
            ],
          ),
          bottom: TabBar(tabs: [
            Tab(text: "inputs".tr),
            Tab(text: "outputs".tr),
          ]),
        ),
        body: TabBarView(children: [
          _InputOrdering(
            inputs: inputs,
            network: widget.network,
            onUpdate: onUpdate,
          ),
          _OutputOrdering(
            outputs: outputs,
            network: widget.network,
            onUpdate: onUpdate,
          )
        ]),
      ),
    );
  }
}

class _InputOrdering extends StatelessWidget {
  const _InputOrdering(
      {required this.inputs, required this.network, required this.onUpdate});
  final List<_InputsWithKey> inputs;
  final WalletBitcoinNetwork network;
  final DynamicVoid onUpdate;

  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      buildDefaultDragHandles: false,
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) newIndex--;
        final item = inputs.removeAt(oldIndex);
        inputs.insert(newIndex, item);
        onUpdate();
      },
      children: List.generate(inputs.length, (index) {
        final input = inputs[index];
        return Padding(
          padding: WidgetConstant.paddingHorizontal20,
          key: input.key,
          child: ConstraintsBoxView(
            child: ContainerWithBorder(
              onRemove: () {},
              onTapWhenOnRemove: false,
              onRemoveIcon: ReorderableDragStartListener(
                  index: index, child: const Icon(Icons.drag_handle)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                            input.item.ownerDetails.address.type.value.tr,
                            style: context.textTheme.labelLarge),
                      ),
                      SelectableView(text: index.toString()),
                    ],
                  ),
                  OneLineTextWidget(input.item.ownerDetails.address
                      .toAddress(network.coinParam.transacationNetwork)),
                  Divider(color: context.colors.onPrimaryContainer),
                  OneLineTextWidget(input.item.utxo.txHash),
                  Text(input.item.utxo.vout.toString()),
                  CoinPriceView(
                      token: network.coinParam.token,
                      balance: input.inputValue,
                      style: context.textTheme.titleLarge)
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _OutputOrdering extends StatelessWidget {
  const _OutputOrdering(
      {required this.outputs, required this.network, required this.onUpdate});
  final List<_OutputWithKey> outputs;
  final WalletBitcoinNetwork network;
  final DynamicVoid onUpdate;

  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) newIndex--;
        final item = outputs.removeAt(oldIndex);
        outputs.insert(newIndex, item);
        onUpdate();
      },
      buildDefaultDragHandles: false,
      children: List.generate(outputs.length, (index) {
        final output = outputs[index];
        return Padding(
          padding: WidgetConstant.paddingHorizontal20,
          key: output.key,
          child: ContainerWithBorder(
            onRemove: () {},
            onTapWhenOnRemove: false,
            onRemoveIcon: ReorderableDragStartListener(
                index: index, child: const Icon(Icons.drag_handle)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                        child: output.output is BitcoinSpendableBaseOutput
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                          child: OneLineTextWidget(
                                              output.addressView!)),
                                      WidgetConstant.width8,
                                      SelectableView(text: index.toString())
                                    ],
                                  ),
                                  CoinPriceView(
                                      token: network.coinParam.token,
                                      balance: output.value),
                                ],
                              )
                            : Text(output.script ?? "")),
                  ],
                ),
                if (output.token != null) ...[
                  Divider(
                    color: context.colors.onPrimaryContainer,
                  ),
                  BCHCashTokenDetailsView(token: output.token!),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _OutputWithKey<T> {
  _OutputWithKey(
      {this.addressView,
      required this.output,
      required this.value,
      this.script,
      this.token})
      : key = GlobalKey();
  factory _OutputWithKey._(
      BitcoinBaseOutput output, WalletBitcoinNetwork network) {
    if (output is BitcoinScriptOutput) {
      return _OutputWithKey(
          output: output,
          value: IntegerBalance.zero(network.coinParam.decimal),
          addressView: null,
          script: BTCUtils.opReturnToView(output.script));
    }
    if (output is BitcoinTokenOutput) {
      return _OutputWithKey(
          output: output,
          addressView:
              output.address.toAddress(network.coinParam.transacationNetwork),
          token: BCHCashToken(cashToken: output.token),
          value: IntegerBalance(
            output.value,
            network.coinParam.decimal,
          ));
    }
    output as BitcoinOutput;
    return _OutputWithKey(
        output: output,
        addressView:
            output.address.toAddress(network.coinParam.transacationNetwork),
        value: IntegerBalance(
          output.value,
          network.coinParam.decimal,
        ));
  }
  final GlobalKey key;
  final String? addressView;
  final BitcoinBaseOutput output;
  final IntegerBalance value;
  final String? script;
  final BCHCashToken? token;
}

class _InputsWithKey {
  _InputsWithKey({required this.item}) : key = GlobalKey();
  final GlobalKey key;
  final UtxoWithAddress item;
  late final inputValue = IntegerBalance(item.utxo.value, BTCUtils.decimal);
}
