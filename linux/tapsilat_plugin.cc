#include "include/tapsilat/tapsilat_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>

namespace {

const char kChannelName[] = "tapsilat";

typedef struct _TapsilatPlugin {
  GObject parent_instance;
} TapsilatPlugin;

G_DEFINE_TYPE(TapsilatPlugin, tapsilat_plugin, g_object_get_type())

// Handles method channel calls by answering not implemented.
static void HandleMethodCall(TapsilatPlugin* self, FlMethodCall* method_call) {
  const gchar* method = fl_method_call_get_name(method_call);

  if (g_strcmp0(method, "getPlatformVersion") == 0) {
    struct utsname uname_data;
    uname(&uname_data);
    g_autofree gchar* version =
        g_strdup_printf("Linux %s", uname_data.version);
    g_autoptr(FlValue) result_value = fl_value_new_string(version);
    g_autoptr(FlMethodResponse) response = FL_METHOD_RESPONSE(
        fl_method_success_response_new(result_value));
    fl_method_call_respond(method_call, response, nullptr);
    return;
  }

  g_autoptr(FlMethodResponse) response =
      FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  fl_method_call_respond(method_call, response, nullptr);
}

static void tapsilat_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(tapsilat_plugin_parent_class)->dispose(object);
}

static void tapsilat_plugin_class_init(TapsilatPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = tapsilat_plugin_dispose;
}

static void tapsilat_plugin_init(TapsilatPlugin* self) {}

static void MethodCallHandler(FlMethodChannel* channel,
                              FlMethodCall* method_call,
                              gpointer user_data) {
  auto* plugin = TAPSILAT_PLUGIN(user_data);
  HandleMethodCall(plugin, method_call);
}

}  // namespace

void tapsilat_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  TapsilatPlugin* plugin = TAPSILAT_PLUGIN(
      g_object_new(tapsilat_plugin_get_type(), nullptr));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel = fl_method_channel_new(
      fl_plugin_registrar_get_messenger(registrar), kChannelName,
      FL_METHOD_CODEC(codec));

  fl_method_channel_set_method_call_handler(channel, MethodCallHandler,
                                            g_object_ref(plugin),
                                            g_object_unref);

  g_object_unref(plugin);
}
