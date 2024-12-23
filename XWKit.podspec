#
# Be sure to run `pod lib lint XWKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XWKit'
  s.version          = '1.0.0'
  s.summary          = '基础扩展'

  

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/Jay/XWKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Jay' => 'jayorw@126.com' }
  s.source           = { :git => 'https://github.com/Jay/XWKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'
  s.requires_arc = true
  s.static_framework = true
  s.swift_versions = ['5']

  
  
  s.subspec "Extension" do |ss|
    ss.source_files  = "XWKit/Classes/Extension/*"
  end
  
  s.subspec "Namespace" do |ss|
    ss.source_files  = "XWKit/Classes/Namespace/*"
  end
  
  s.subspec "Core" do |ss|
    ss.source_files  = "XWKit/Classes/Core/*"
  end
  
  s.subspec "BaseUI" do |ss|
    ss.source_files  = "XWKit/Classes/BaseUI/*"
    ss.dependency 'SnapKit'
    ss.dependency 'DZNEmptyDataSet'
  end
  
end
