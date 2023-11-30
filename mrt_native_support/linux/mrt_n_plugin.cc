#include "include/mrt_n/mrt_n_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>

#include <cstring>

#define MRT_N_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), mrt_n_plugin_get_type(), \
                              Mrt_nPlugin))

struct _Mrt_nPlugin {
  GObject parent_instance;
};

G_DEFINE_TYPE(Mrt_nPlugin, mrt_n_plugin, g_object_get_type())

// Called when a method call is received from Flutter.
static void mrt_n_plugin_handle_method_call(
    Mrt_nPlugin* self,
    FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar* method = fl_method_call_get_name(method_call);

  if (strcmp(method, "getPlatformVersion") == 0) {
    struct utsname uname_data = {};
    uname(&uname_data);
    g_autofree gchar *version = g_strdup_printf("Linux %s", uname_data.version);
    g_autoptr(FlValue) result = fl_value_new_string(version);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

static void mrt_n_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(mrt_n_plugin_parent_class)->dispose(object);
}

static void mrt_n_plugin_class_init(Mrt_nPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = mrt_n_plugin_dispose;
}

static void mrt_n_plugin_init(Mrt_nPlugin* self) {}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
  Mrt_nPlugin* plugin = MRT_N_PLUGIN(user_data);
  mrt_n_plugin_handle_method_call(plugin, method_call);
}

void mrt_n_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  Mrt_nPlugin* plugin = MRT_N_PLUGIN(
      g_object_new(mrt_n_plugin_get_type(), nullptr));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "mrt_n",
                            FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel, method_call_cb,
                                            g_object_ref(plugin),
                                            g_object_unref);

  g_object_unref(plugin);
}
