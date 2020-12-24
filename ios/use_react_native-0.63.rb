#
# Copyright (c) Microsoft Corporation
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

def include_react_native!(react_native:, target_platform:, project_root:, flipper_versions:)
  require_relative File.join(project_root, react_native, 'scripts', 'react_native_pods')

  if target_platform == :ios && flipper_versions
    use_flipper!(flipper_versions)
    use_flipper_plugin_react_native_performance!(project_root)
  end

  use_react_native!(:path => react_native)
end
