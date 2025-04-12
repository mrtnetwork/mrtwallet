import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/global/pages/receipt_address_view.dart';
import 'package:mrt_wallet/future/wallet/global/pages/select_account_or_contact.dart';
import 'package:mrt_wallet/future/wallet/network/substrate/metadata/metadata.dart';
import 'package:mrt_wallet/future/wallet/network/substrate/metadata/pages/quick_access.dart';
import 'package:mrt_wallet/future/wallet/network/substrate/metadata/forms/metadata.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';
import 'package:mrt_wallet/wallet/models/networks/substrate/substrate.dart';
import 'package:mrt_wallet/wallet/models/others/models/receipt_address.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class SubstrateMetadataAccess<T extends StateController>
    extends InheritedWidget {
  const SubstrateMetadataAccess(
      {super.key, required this.account, required super.child});
  final SubstrateChain account;
  WalletNetwork get network => account.network;
  SubstrateChainMetadata get metadata => account.client.metadata;
  static SubstrateChainMetadata metadataOf(BuildContext context) {
    final repository =
        context.dependOnInheritedWidgetOfExactType<SubstrateMetadataAccess>()!;
    return repository.metadata;
  }

  static SubstrateMetadataAccess of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<SubstrateMetadataAccess>()!;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return oldWidget != this;
  }
}

class SubstrateMetadataValidatorView extends StatelessWidget {
  final MetadataFormValidator validator;
  final SubstrateChain account;
  const SubstrateMetadataValidatorView(
      {super.key, required this.validator, required this.account});

  @override
  Widget build(BuildContext context) {
    return SubstrateMetadataAccess(
        account: account,
        child: _SliverFieldValidatorView(validator: validator));
  }
}

class _SliverFieldValidatorView extends StatelessWidget {
  const _SliverFieldValidatorView({required this.validator, super.key});
  final MetadataFormValidator validator;
  @override
  Widget build(BuildContext context) {
    return switch (validator.runtimeType) {
      const (MetadataFormValidatorBoolean) =>
        _BooleanFieldValidatorView(validator: validator.cast()),
      const (MetadataFormValidatorString) =>
        _StringFieldValidatorView(validator: validator.cast()),
      const (MetadataFormValidatorInt) =>
        _NumericFieldValidatorView(validator: validator.cast()),
      const (MetadataFormValidatorBigInt) =>
        _NumericFieldValidatorView(validator: validator.cast()),
      const (MetadataFormValidatorNone) =>
        _NoneFieldValidatorView(validator: validator.cast()),
      const (MetadataFormValidatorTuple) =>
        _TupleFieldValidatorView(validator: validator.cast()),
      const (MetadataFormValidatorComposit) =>
        _CompositFieldValidatorView(validator: validator.cast()),
      const (MetadataFormValidatorSequence) =>
        _SequenceFieldValidatorView(validator: validator.cast()),
      const (MetadataFormValidatorVariant) =>
        _VariantFieldValidatorView(validator: validator.cast()),
      const (MetadataFormValidatorBytes) =>
        _BytesFieldValidatorView(validator: validator.cast()),
      _ => SliverToBoxAdapter(
          child: ContainerWithBorder(
              child: Text("unknow! ${validator.toString()}")))
    };
  }
}

class _BooleanFieldValidatorView extends StatelessWidget {
  const _BooleanFieldValidatorView({required this.validator});
  final MetadataFormValidatorBoolean validator;
  @override
  Widget build(BuildContext context) {
    return LiveWidget(
      () {
        return SliverMainAxisGroup(
          slivers: [
            WidgetConstant.sliverPaddingVertial10,
            _SliverFieldNameView(validator.info),
            _Wrap(
              field: validator,
              child: ContainerWithBorder(
                  validate: validator.isValid,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("false".tr),
                      WidgetConstant.width8,
                      Switch(
                          value: validator.value.value ?? false,
                          onChanged: validator.setValue),
                      WidgetConstant.width8,
                      Text("true".tr)
                    ],
                  )),
            ),
          ],
        );
      },
    );
  }
}

enum _QuickAccessOptions {
  storage("storages"),
  runtimeApi("runtime_apis"),
  constants("constants"),
  utf8Encoder("utf8_encoder"),
  transactionVersion("transaction_version"),
  specVersion("spec_version"),
  addressDecoder("address_decoder"),
  genesisHash("genesis_hash"),
  bytesTools("bytes_tools"),
  finalizBlock("finaliz_block"),
  accounts("accounts"),
  pow7("7^10"),
  powN("n^10"),
  pow10("10^10"),
  pow12("12^10"),
  pow18("18^10");

  static _QuickAccessOptions? fromScale(int? pow) {
    if (pow == null) return null;
    switch (pow) {
      case 7:
        return _QuickAccessOptions.pow7;
      case 10:
        return _QuickAccessOptions.pow10;
      case 12:
        return _QuickAccessOptions.pow12;
      case 18:
        return _QuickAccessOptions.pow18;
      default:
        return _QuickAccessOptions.powN;
    }
  }

  static List<_QuickAccessOptions> globalOptions(
      SubstrateChainMetadata metadata) {
    return [
      _QuickAccessOptions.constants,
      _QuickAccessOptions.storage,
      if (metadata.supportRuntimeApi) _QuickAccessOptions.runtimeApi,
    ];
  }

  final String name;
  const _QuickAccessOptions(this.name);
}

class _NumericFieldValidatorView extends StatelessWidget {
  const _NumericFieldValidatorView({required this.validator});
  final MetadataFormValidatorNumeric validator;
  @override
  Widget build(BuildContext context) {
    return LiveWidget(() {
      return SliverMainAxisGroup(
        slivers: [
          WidgetConstant.sliverPaddingVertial10,
          _SliverFieldNameView(validator.info),
          _Wrap(
            field: validator,
            child: ContainerWithBorder(
                validate: validator.isValid,
                onRemove: () {},
                enableTap: false,
                onRemoveWidget: _QuickAccessPopupMenuButton(
                    checked: _QuickAccessOptions.fromScale(validator.maxScale),
                    icon: ConditionalWidget(
                      onActive: (context) => Text("${validator.maxScale}^10",
                          style: context.onPrimaryTextTheme.labelLarge),
                      enable: validator.maxScale != null,
                      onDeactive: (context) =>
                          Icon(Icons.menu, color: context.onPrimaryContainer),
                    ),
                    onselectoption: (value) {
                      final metadata = SubstrateMetadataAccess.of(context);
                      switch (value) {
                        case _QuickAccessOptions.transactionVersion:
                          validator.setIntValue(
                              metadata.metadata.transactionVersion);
                          break;
                        case _QuickAccessOptions.specVersion:
                          validator.setIntValue(metadata.metadata.specVersion);
                          break;
                        case _QuickAccessOptions.powN:
                          validator.setPow(metadata.network.coinDecimal);
                          break;
                        case _QuickAccessOptions.pow10:
                        case _QuickAccessOptions.pow7:
                        case _QuickAccessOptions.pow12:
                        case _QuickAccessOptions.pow18:
                          final pow = int.parse(value.name.split("^")[0]);
                          validator.setPow(pow);
                          break;
                        default:
                          break;
                      }
                    },
                    option: validator.enableDecimal
                        ? _QuickAccessType.numbers
                        : null),
                child: BigRationalTextField(
                    key: validator.textFieldKey,
                    label: validator.info.viewName ?? '',
                    onChange: validator.onChangeValue,
                    defaultValue: validator.value.value,
                    validator: validator.validate,
                    maxScale: validator.maxScale,
                    max: validator.max,
                    min: validator.min)),
          ),
        ],
      );
    });
  }
}

class _NoneFieldValidatorView extends StatelessWidget {
  const _NoneFieldValidatorView({required this.validator});
  final MetadataFormValidatorNone validator;
  @override
  Widget build(BuildContext context) {
    return WidgetConstant.sliverSizedBox;
  }
}

class _StringFieldValidatorView extends StatelessWidget {
  const _StringFieldValidatorView({required this.validator});
  final MetadataFormValidatorString validator;
  @override
  Widget build(BuildContext context) {
    return LiveWidget(() {
      return SliverMainAxisGroup(
        slivers: [
          WidgetConstant.sliverPaddingVertial10,
          _SliverFieldNameView(validator.info),
          _Wrap(
            field: validator,
            child: ContainerWithBorder(
              validate: validator.isValid,
              onRemove: () {
                context
                    .openSliverBottomSheet<String>(
                      validator.info.viewName ?? 'input_string'.tr,
                      child: StringWriterView(
                          defaultValue: validator.value.value,
                          title: Text("string".tr),
                          label: "string".tr,
                          buttonText: 'setup'.tr),
                    )
                    .then(validator.setValue);
              },
              onRemoveIcon:
                  Icon(Icons.add_box, color: context.onPrimaryContainer),
              child: _ValueOrTapInputValue(value: validator.value.value),
            ),
          ),
        ],
      );
    });
  }
}

class _BytesFieldValidatorView extends StatelessWidget {
  const _BytesFieldValidatorView({required this.validator});
  final MetadataFormValidatorBytes validator;
  @override
  Widget build(BuildContext context) {
    return LiveWidget(() {
      final String? value = validator.value;
      return SliverMainAxisGroup(
        slivers: [
          WidgetConstant.sliverPaddingVertial10,
          _SliverFieldNameView(validator.info),
          _Wrap(
            field: validator,
            child: ContainerWithBorder(
              validate: validator.isValid,
              onRemove: () {},
              enableTap: false,
              onRemoveWidget: ConditionalWidget(
                onActive: (context) => _QuickAccessPopupMenuButton(
                    bytesLength: validator.length,
                    onselectoption: (value) async {
                      final metadata = SubstrateMetadataAccess.of(context);
                      switch (value) {
                        case _QuickAccessOptions.accounts:
                          context
                              .openSliverBottomSheet<
                                  ReceiptAddress<BaseSubstrateAddress>>(
                                validator.info.name ?? "address".tr,
                                bodyBuilder: (scrollController) =>
                                    SelectRecipientAccountView<
                                            BaseSubstrateAddress>(
                                        account: metadata.account,
                                        scrollController: scrollController,
                                        multipleSelect: false),
                              )
                              .then(validator.setAddress);
                          break;
                        case _QuickAccessOptions.addressDecoder:
                          final r = await context.openSliverBottomSheet<String>(
                              'address_decoder'.tr,
                              child: const AddressDecoderView());
                          if (r == null) return;
                          validator.setValue(r);
                          break;
                        case _QuickAccessOptions.genesisHash:
                          validator.setValue(metadata.metadata.genesis);
                          break;
                        case _QuickAccessOptions.utf8Encoder:
                          final r = await context.openSliverBottomSheet<String>(
                              'utf8_encoder'.tr,
                              child: const UTF8EncoderView());
                          if (r == null) return;
                          validator.setValue(r);
                          break;
                        default:
                          break;
                      }
                    },
                    option: _QuickAccessType.bytes),
                enable: validator.address == null,
                onDeactive: (context) {
                  return IconButton(
                      onPressed: validator.removeAddress,
                      icon: Icon(Icons.remove_circle,
                          color: context.colors.onPrimaryContainer));
                },
              ),
              child: ConditionalWidget(
                onActive: (context) => AppTextField(
                    key: validator.textFieldKey,
                    maxLines: 2,
                    minlines: 1,
                    validator: validator.validate,
                    onChanged: validator.onChangeValue,
                    label: validator.type.viewName ?? "bytes".tr,
                    pasteIcon: true,
                    initialValue: value),
                enable: validator.address == null,
                onDeactive: (context) =>
                    ReceiptAddressDetailsView(address: validator.address!),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _SequenceFieldValidatorView extends StatelessWidget {
  const _SequenceFieldValidatorView({required this.validator});
  final MetadataFormValidatorSequence validator;
  @override
  Widget build(BuildContext context) {
    return LiveWidget(() {
      final List<MetadataFormValidator> validators = validator.validators;
      return SliverMainAxisGroup(slivers: [
        ...List.generate(
          validators.length,
          (index) {
            final v = validators[index];
            return _SliverFieldValidatorView(validator: v);
          },
        ),
        _Wrap(
          field: validator,
          child: ConditionalWidgets(enable: validator.immutable, widgets: {
            true: (context) => WidgetConstant.sizedBox,
            false: (context) => ContainerWithBorder(
                  onRemove: () {
                    validator.add();
                  },
                  onRemoveIcon:
                      Icon(Icons.add_box, color: context.onPrimaryContainer),
                  child: Text("tap_to_create_object"
                      .tr
                      .replaceOne(validator.info.viewName ?? '')),
                )
          }),
        )
      ]);
    });
  }
}

class _TupleFieldValidatorView extends StatelessWidget {
  const _TupleFieldValidatorView({required this.validator});
  final MetadataFormValidatorTuple validator;
  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        ...List.generate(validator.validators.length, (index) {
          final field = validator.validators[index];
          return _SliverFieldValidatorView(validator: field);
        }),
      ],
    );
  }
}

class _CompositFieldValidatorView extends StatelessWidget {
  const _CompositFieldValidatorView({required this.validator});
  final MetadataFormValidatorComposit validator;
  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        ...List.generate(validator.validators.length, (index) {
          final field = validator.validators[index];
          return _SliverFieldValidatorView(validator: field);
        })
      ],
    );
  }
}

class _VariantFieldValidatorView extends StatelessWidget {
  const _VariantFieldValidatorView({required this.validator});
  final MetadataFormValidatorVariant validator;
  @override
  Widget build(BuildContext context) {
    final metadata = SubstrateMetadataAccess.metadataOf(context);
    validator.items ??= {
      for (final i in validator.info.variants)
        i: Text(i.name.camelCase, style: context.textTheme.titleMedium),
    };
    return LiveWidget(() {
      return SliverMainAxisGroup(
        slivers: [
          WidgetConstant.sliverPaddingVertial10,
          _SliverFieldNameView(validator.info),
          _Wrap(
            field: validator,
            child: ContainerWithBorder(
              validate: validator.isValid,
              child: AppDropDownBottom(
                  isExpanded: true,
                  items: validator.items!,
                  onChanged: (variant) {
                    if (variant == null) return;
                    validator.setVariant(
                        variant: variant,
                        type: metadata.getTypeInfo(variant).cast());
                  },
                  value: validator.variant,
                  hint: validator.info.viewName),
            ),
          ),
          APPSliverAnimatedSwitcher(enable: validator.hasVariant, widgets: {
            true: (context) => SliverPadding(
                  padding: WidgetConstant.paddingHorizontal10,
                  sliver: _SliverFieldValidatorView(
                      key: ValueKey<Si1Variant?>(validator.variant),
                      validator: validator.validator!),
                )
          }),
        ],
      );
    });
  }
}

class _WrapSliver extends StatelessWidget {
  const _WrapSliver({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(child: child);
  }
}

class _Wrap extends StatelessWidget {
  const _Wrap({required this.field, required this.child});
  final MetadataFormValidator field;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    if (field.onRemove == null) return _WrapSliver(child: child);
    return _WrapSliver(
      child: ContainerWithBorder(
          onRemoveWidget:
              Icon(Icons.remove_circle, color: context.colors.onSurface),
          onRemove: field.onRemove,
          backgroundColor: context.colors.surface,
          child: child),
    );
  }
}

typedef _ONSELECTOPTION = void Function(_QuickAccessOptions);

enum _QuickAccessType {
  numbers,
  bytes;

  List<_QuickAccessOptions> bytesOptions({int? length}) {
    if (this != _QuickAccessType.bytes) return [];
    if (length == SubstrateConstant.accountIdLengthInBytes) {
      return [
        _QuickAccessOptions.accounts,
        _QuickAccessOptions.addressDecoder,
        _QuickAccessOptions.bytesTools,
        _QuickAccessOptions.finalizBlock,
        _QuickAccessOptions.genesisHash
      ];
    } else if (length == SubstrateConstant.accountId20LengthInBytes) {
      return [_QuickAccessOptions.accounts, _QuickAccessOptions.bytesTools];
    }
    return [_QuickAccessOptions.utf8Encoder, _QuickAccessOptions.bytesTools];
  }

  List<_QuickAccessOptions> numberOptions(int networkDecimal) {
    if (this != _QuickAccessType.numbers) return [];
    bool hasOption =
        _QuickAccessOptions.values.any((e) => e.name == "$networkDecimal^10");
    return [
      _QuickAccessOptions.transactionVersion,
      _QuickAccessOptions.specVersion,
      _QuickAccessOptions.pow10,
      _QuickAccessOptions.pow12,
      _QuickAccessOptions.pow18,
      if (!hasOption) _QuickAccessOptions.powN
    ];
  }
}

class _QuickAccessPopupMenuButton extends StatelessWidget {
  const _QuickAccessPopupMenuButton(
      {required this.onselectoption,
      required this.option,
      this.bytesLength,
      this.checked,
      this.icon});
  final int? bytesLength;
  final _QuickAccessType? option;
  final _ONSELECTOPTION onselectoption;
  final Widget? icon;
  final _QuickAccessOptions? checked;

  @override
  Widget build(BuildContext context) {
    final metadata = SubstrateMetadataAccess.of(context);
    return PopupMenuButton<_QuickAccessOptions>(
      icon: icon ?? Icon(Icons.menu, color: context.onPrimaryContainer),
      itemBuilder: (context) {
        List<PopupMenuEntry<_QuickAccessOptions>> customOptions() {
          final op = option;
          if (op == null) return [];
          return [
            const PopupMenuDivider(),
            ...op.bytesOptions(length: bytesLength).map((e) {
              return PopupMenuItem(value: e, child: Text(e.name.tr));
            }),
            ...op.numberOptions(metadata.network.coinDecimal).map((e) {
              switch (e) {
                case _QuickAccessOptions.powN:
                  return CheckedPopupMenuItem(
                      value: e,
                      checked: e == checked,
                      child: Text("${metadata.network.coinDecimal}^10"));
                case _QuickAccessOptions.pow7:
                case _QuickAccessOptions.pow10:
                case _QuickAccessOptions.pow18:
                case _QuickAccessOptions.pow12:
                  return CheckedPopupMenuItem(
                      value: e, checked: e == checked, child: Text(e.name.tr));
                default:
              }
              return PopupMenuItem(value: e, child: Text(e.name.tr));
            })
          ];
        }

        final List<PopupMenuEntry<_QuickAccessOptions>> options = [
          ..._QuickAccessOptions.globalOptions(metadata.metadata)
              .map((e) => PopupMenuItem(value: e, child: Text(e.name.tr))),
          ...customOptions()
        ];
        return options;
      },
      onSelected: (value) async {
        switch (value) {
          case _QuickAccessOptions.constants:
            context.openSliverBottomSheet('constants'.tr,
                bodyBuilder: (scrollController) =>
                    SubstrateMetadataConstantsView(
                      scrollController: scrollController,
                      account: metadata.account,
                    ));
            break;
          case _QuickAccessOptions.storage:
            context.openSliverBottomSheet('storages'.tr,
                bodyBuilder: (scrollController) =>
                    SubstrateMetadataRuntimeApiView(
                      scrollController: scrollController,
                      account: metadata.account,
                    ));
            break;
          case _QuickAccessOptions.runtimeApi:
            context.openSliverBottomSheet('runtime_apis'.tr,
                bodyBuilder: (scrollController) =>
                    SubstrateMetadataStoragesView(
                        scrollController: scrollController,
                        account: metadata.account));
            break;
          case _QuickAccessOptions.bytesTools:
            context.openSliverBottomSheet('bytes_tools'.tr,
                child: const BytesToolsView());
            break;
          case _QuickAccessOptions.finalizBlock:
            context.openSliverBottomSheet('finaliz_block'.tr,
                bodyBuilder: (scrollController) => SubstrateQuickAccessView(
                    scrollController: scrollController,
                    chain: metadata.account));
            break;
          default:
            onselectoption(value);
        }
      },
    );
  }
}

class _ValueOrTapInputValue extends StatelessWidget {
  const _ValueOrTapInputValue({this.value});
  final String? value;
  @override
  Widget build(BuildContext context) {
    return ConditionalWidget(
        onActive: (context) => Text(value!,
            style: context.onPrimaryTextTheme.bodyMedium, maxLines: 3),
        onDeactive: (context) => Text("tap_to_input_value".tr,
            style: context.onPrimaryTextTheme.bodyMedium),
        enable: value != null);
  }
}

class _SliverFieldNameView extends StatelessWidget {
  const _SliverFieldNameView(this.type);
  final MetadataTypeInfo type;

  @override
  Widget build(BuildContext context) {
    return ConditionalWidgets(enable: type.viewName == null, widgets: {
      true: (context) => WidgetConstant.sliverSizedBox,
      false: (context) => SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(type.viewName!, style: context.textTheme.titleMedium),
                WidgetConstant.height8
              ],
            ),
          ),
    });
  }
}
