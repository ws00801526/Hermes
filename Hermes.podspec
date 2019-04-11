#
# Be sure to run `pod lib lint Hermes.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Hermes'
  s.version          = '0.1.0'
  s.summary          = 'A simple,lightweight middleware for communication'
  s.homepage         = 'https://github.com/ws00801526/Hermes'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ws00801526' => '3057600441@qq.com' }
  s.source           = { :git => 'https://github.com/ws00801526/Hermes.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.default_subspecs = 'Router', 'EventBus', 'Module'
  s.swift_version = '5.0'
  s.subspec 'Router' do |ss|
      ss.source_files = 'Hermes/Classes/Router.swift'
  end

  s.subspec 'EventBus' do |ss|
      ss.source_files = 'Hermes/Classes/EventBus.swift'
  end
  
  s.subspec 'Module' do |ss|
      ss.source_files = 'Hermes/Classes/Module.swift', 'Hermes/Classes/Items.swift'
    end
end
