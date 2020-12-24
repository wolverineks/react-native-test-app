#
# Copyright (c) Microsoft Corporation. All rights reserved.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

def resolve_module(request)
  script = "console.log(path.dirname(require.resolve('#{request}/package.json')));"
  Pod::Executable.execute_command('node', ['-e', script], true).strip
end

def try_pod(name, podspec, project_root)
  pod name, :podspec => podspec if File.exist?(File.join(project_root, podspec))
end

def use_flipper_plugin_react_native_performance!(project_root)
  flipper_plugin_react_native_performance = 'flipper-plugin-react-native-performance'
  begin
    path = Pathname.new(resolve_module(flipper_plugin_react_native_performance))
    pod flipper_plugin_react_native_performance,
        :path => File.join(path.relative_path_from(project_root).to_s, 'ios'),
        :configuration => 'Debug'
  rescue StandardError
    # Ignore if not installed
  end
end
