#
# Copyright (c) Microsoft Corporation. All rights reserved.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

def autolink_script_path()
  package_path = resolve_module('@react-native-community/cli-platform-ios')
  return File.join(package_path, 'native_modules')
end

def resolve_module(request)
  script = "console.log(path.dirname(require.resolve('#{request}/package.json')));"
  return Pod::Executable.execute_command('node', ['-e', script], true).strip
end

def use_test_app!(project_root)
  platform :ios, '12.0'

  xcodeproj = 'ReactTestApp.xcodeproj'
  if project_root != __dir__
    src_xcodeproj = File.join(__dir__, 'ios', xcodeproj)
    destination = File.join(resolve_module('react-native-test-app'), '..', '.generated')
    dst_xcodeproj = File.join(destination, xcodeproj)

    # Copy/link Xcode project files
    FileUtils.mkdir_p(dst_xcodeproj)
    FileUtils.cp(File.join(src_xcodeproj, 'project.pbxproj'), dst_xcodeproj)
    FileUtils.ln_sf(File.join(src_xcodeproj, 'xcshareddata'), dst_xcodeproj)

    # Link source files
    ['ReactTestApp', 'ReactTestAppTests', 'ReactTestAppUITests'].each do |file|
      FileUtils.ln_sf(File.join(__dir__, 'ios', file), destination)
    end

    project dst_xcodeproj

    post_install do |installer|
      puts ''
      puts 'NOTE'
      puts "  `#{xcodeproj}` was sourced from `react-native-test-app`"
      puts '  All modifications will be overwritten next time you run `pod install`'
      puts ''
    end
  else
    project xcodeproj
  end

  require_relative autolink_script_path

  react_native = Pathname.new(resolve_module('react-native'))
    .relative_path_from(Pathname.new(project_root))
    .to_s

  target 'ReactTestApp' do
    pod 'QRCodeReader.swift'
    pod 'SwiftLint'

    # React Native
    pod 'FBLazyVector', :path => "#{react_native}/Libraries/FBLazyVector"
    pod 'FBReactNativeSpec', :path => "#{react_native}/Libraries/FBReactNativeSpec"
    pod 'RCTRequired', :path => "#{react_native}/Libraries/RCTRequired"
    pod 'RCTTypeSafety', :path => "#{react_native}/Libraries/TypeSafety"
    pod 'React', :path => "#{react_native}/"
    pod 'React-Core', :path => "#{react_native}/", :inhibit_warnings => true
    pod 'React-CoreModules', :path => "#{react_native}/React/CoreModules"
    pod 'React-Core/DevSupport', :path => "#{react_native}/"
    pod 'React-RCTActionSheet', :path => "#{react_native}/Libraries/ActionSheetIOS"
    pod 'React-RCTAnimation', :path => "#{react_native}/Libraries/NativeAnimation"
    pod 'React-RCTBlob', :path => "#{react_native}/Libraries/Blob"
    pod 'React-RCTImage', :path => "#{react_native}/Libraries/Image"
    pod 'React-RCTLinking', :path => "#{react_native}/Libraries/LinkingIOS"
    pod 'React-RCTNetwork', :path => "#{react_native}/Libraries/Network"
    pod 'React-RCTSettings', :path => "#{react_native}/Libraries/Settings"
    pod 'React-RCTText', :path => "#{react_native}/Libraries/Text", :inhibit_warnings => true
    pod 'React-RCTVibration', :path => "#{react_native}/Libraries/Vibration"
    pod 'React-Core/RCTWebSocket', :path => "#{react_native}/"

    pod 'React-cxxreact', :path => "#{react_native}/ReactCommon/cxxreact", :inhibit_warnings => true
    pod 'React-jsi', :path => "#{react_native}/ReactCommon/jsi"
    pod 'React-jsiexecutor', :path => "#{react_native}/ReactCommon/jsiexecutor"
    pod 'React-jsinspector', :path => "#{react_native}/ReactCommon/jsinspector"
    pod 'ReactCommon/jscallinvoker', :path => "#{react_native}/ReactCommon"
    pod 'ReactCommon/turbomodule/core', :path => "#{react_native}/ReactCommon"
    pod 'Yoga', :path => "#{react_native}/ReactCommon/yoga"

    pod 'DoubleConversion', :podspec => "#{react_native}/third-party-podspecs/DoubleConversion.podspec"
    pod 'glog', :podspec => "#{react_native}/third-party-podspecs/glog.podspec"
    pod 'Folly', :podspec => "#{react_native}/third-party-podspecs/Folly.podspec"

    yield 'app'

    target 'ReactTestAppTests' do
      inherit! :search_paths
      yield 'tests'
    end

    target 'ReactTestAppUITests' do
      inherit! :search_paths
      yield 'uitests'
    end

    use_native_modules!
  end
end
