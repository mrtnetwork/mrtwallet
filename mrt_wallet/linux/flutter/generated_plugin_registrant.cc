//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <mrt_native_support/mrt_native_support.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) mrt_native_support_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "MrtNativeSupport");
  mrt_native_support_register_with_registrar(mrt_native_support_registrar);
}
