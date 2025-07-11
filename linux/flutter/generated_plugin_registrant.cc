//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <flutter_libserialport/flutter_libserialport_plugin.h>
#include <flutter_nesigner_sdk/flutter_nesigner_sdk_plugin.h>
#include <flutter_secure_storage_linux/flutter_secure_storage_linux_plugin.h>
#include <isar_flutter_libs/isar_flutter_libs_plugin.h>
#include <nesigner_adapter/nesigner_adapter_plugin.h>
#include <open_file_linux/open_file_linux_plugin.h>
#include <screen_retriever_linux/screen_retriever_linux_plugin.h>
#include <window_manager/window_manager_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) flutter_libserialport_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "FlutterLibserialportPlugin");
  flutter_libserialport_plugin_register_with_registrar(flutter_libserialport_registrar);
  g_autoptr(FlPluginRegistrar) flutter_nesigner_sdk_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "FlutterNesignerSdkPlugin");
  flutter_nesigner_sdk_plugin_register_with_registrar(flutter_nesigner_sdk_registrar);
  g_autoptr(FlPluginRegistrar) flutter_secure_storage_linux_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "FlutterSecureStorageLinuxPlugin");
  flutter_secure_storage_linux_plugin_register_with_registrar(flutter_secure_storage_linux_registrar);
  g_autoptr(FlPluginRegistrar) isar_flutter_libs_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "IsarFlutterLibsPlugin");
  isar_flutter_libs_plugin_register_with_registrar(isar_flutter_libs_registrar);
  g_autoptr(FlPluginRegistrar) nesigner_adapter_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "NesignerAdapterPlugin");
  nesigner_adapter_plugin_register_with_registrar(nesigner_adapter_registrar);
  g_autoptr(FlPluginRegistrar) open_file_linux_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "OpenFileLinuxPlugin");
  open_file_linux_plugin_register_with_registrar(open_file_linux_registrar);
  g_autoptr(FlPluginRegistrar) screen_retriever_linux_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "ScreenRetrieverLinuxPlugin");
  screen_retriever_linux_plugin_register_with_registrar(screen_retriever_linux_registrar);
  g_autoptr(FlPluginRegistrar) window_manager_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "WindowManagerPlugin");
  window_manager_plugin_register_with_registrar(window_manager_registrar);
}
