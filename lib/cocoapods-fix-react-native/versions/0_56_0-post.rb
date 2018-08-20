require 'cocoapods'
require 'cocoapods-fix-react-native/helpers/root_helper'

# Obtain the React Native root directory
$root = get_root

# Detect CocoaPods + Frameworks
$has_frameworks = File.exists?'Pods/Target Support Files/React/React-umbrella.h'

# TODO: move to be both file in pods and file in node_mods?
def patch_pod_file(path, old_code, new_code)
  file = File.join($root, path)
  unless File.exist?(file)
    Pod::UI.warn "#{file} does not exist so was not patched.."
    return
  end
  code = File.read(file)
  if code.include?(old_code)
    Pod::UI.message "Patching #{file}", '- '
    FileUtils.chmod('+w', file)
    File.write(file, code.sub(old_code, new_code))
  end
end

# Detect source file dependency in the generated Pods.xcodeproj workspace sub-project
def has_pods_project_source_file(source_filename)
  pods_project = 'Pods/Pods.xcodeproj/project.pbxproj'
  File.open(pods_project).grep(/#{source_filename}/).any?
end

# Detect dependent source file required for building when the given source file is present
def meets_pods_project_source_dependency(source_filename, dependent_source_filename)
  has_pods_project_source_file(source_filename) ? has_pods_project_source_file(dependent_source_filename) : true
end

def detect_missing_subspec_dependency(subspec_name, source_filename, dependent_source_filename)
  unless meets_pods_project_source_dependency(source_filename, dependent_source_filename)
    Pod::UI.warn "#{subspec_name} subspec may be required given your current dependencies"
  end
end

def detect_missing_subspecs
  return unless $has_frameworks

  # For CocoaPods + Frameworks, RCTNetwork and CxxBridge subspecs are necessary for DevSupport.
  # When the React pod is generated it must include all the required source, and see umbrella deps.
  detect_missing_subspec_dependency('RCTNetwork', 'RCTBlobManager.mm', 'RCTNetworking.mm')
  detect_missing_subspec_dependency('CxxBridge', 'RCTJavaScriptLoader.mm', 'RCTCxxBridge.mm')

  # RCTText itself shouldn't require DevSupport, but it depends on Core -> RCTDevSettings -> RCTPackagerClient
  detect_missing_subspec_dependency('DevSupport', 'RCTDevSettings.mm', 'RCTPackagerClient.m')
end

detect_missing_subspecs

# # https://github.com/facebook/react-native/pull/14664
animation_view_file = 'Libraries/NativeAnimation/RCTNativeAnimatedNodesManager.h'
animation_view_old_code = 'import <RCTAnimation/RCTValueAnimatedNode.h>'
animation_view_new_code = 'import "RCTValueAnimatedNode.h"'
patch_pod_file animation_view_file, animation_view_old_code, animation_view_new_code

# fixes for realm-js
bridge_private_file = 'React/Base/RCTBridge+Private.h'
bridge_private_old_code = 'import <React/RCTBridge.h>'
bridge_private_new_code = 'import "RCTBridge.h"'
patch_pod_file bridge_private_file, bridge_private_old_code, bridge_private_new_code

bridge_file = 'React/Base/RCTBridge.h'
bridge_old_code = 'import <React/RCTBridgeDelegate.h>'
bridge_new_code = 'import "RCTBridgeModule.h"'
patch_pod_file bridge_file, bridge_old_code, bridge_new_code

bridge1_old_code = 'import <React/RCTBridgeModule.h>'
bridge1_new_code = 'import "RCTBridgeDelegate.h"'
patch_pod_file bridge_file, bridge1_old_code, bridge1_new_code

bridge2_old_code = 'import <React/RCTDefines.h>'
bridge2_new_code = 'import "RCTDefines.h"'
patch_pod_file bridge_file, bridge2_old_code, bridge2_new_code

bridge3_old_code = 'import <React/RCTFrameUpdate.h>'
bridge3_new_code = 'import "RCTFrameUpdate.h"'
patch_pod_file bridge_file, bridge3_old_code, bridge3_new_code

bridge4_old_code = 'import <React/RCTInvalidating.h>'
bridge4_new_code = 'import "RCTInvalidating.h"'
patch_pod_file bridge_file, bridge4_old_code, bridge4_new_code

bridge_delegate_file = 'React/Base/RCTBridgeDelegate.h'
bridge_delegate_old_code = 'import <React/RCTJavaScriptLoader.h>'
bridge_delegate_new_code = 'import "RCTJavaScriptLoader.h"'
patch_pod_file bridge_delegate_file, bridge_delegate_old_code, bridge_delegate_new_code

javascript_loader_file = 'React/Base/RCTJavaScriptLoader.h'
javascript_loader_old_code = 'import <React/RCTDefines.h>'
javascript_loader_new_code = 'import "RCTDefines.h"'
patch_pod_file javascript_loader_file, javascript_loader_old_code, javascript_loader_new_code

bridge_module_file = 'React/Base/RCTBridgeModule.h'
bridge_module_old_code = 'import <React/RCTDefines.h>'
bridge_module_new_code = 'import "RCTDefines.h"'
patch_pod_file bridge_module_file, bridge_module_old_code, bridge_module_new_code

javascript_executor_file = 'React/Base/RCTJavaScriptExecutor.h'
javascript_executor_old_code = 'import <React/RCTBridgeModule.h>'
javascript_executor_new_code = 'import "RCTBridgeModule.h"'
patch_pod_file javascript_executor_file, javascript_executor_old_code, javascript_executor_new_code

javascript_executor1_old_code = 'import <React/RCTInvalidating.h>'
javascript_executor1_new_code = 'import "RCTInvalidating.h"'
patch_pod_file javascript_executor_file, javascript_executor1_old_code, javascript_executor1_new_code
