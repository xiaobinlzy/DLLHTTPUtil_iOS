#
# Be sure to run `pod lib lint DLLHTTPRequest.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DLLHTTPRequest'
  s.version          = '0.3.2'
  s.summary          = '网络请求中间层'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
网络请求中间层，底层实现采用AFNetworking。
                       DESC

  s.homepage         = 'https://github.com/xiaobinlzy/DLLHTTPUtil_iOS'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'xiaobinlzy' => 'xiaobinlzy@163.com' }
  s.default_subspec  = 'Binary'
  s.source  = { :git => 'https://github.com/xiaobinlzy/DLLHTTPUtil_iOS.git', :tag => s.version.to_s }
  s.public_header_files = 'Classes/*.h'
  s.source_files = 'Classes/*.h'
  s.dependency 'AFNetworking'
  s.ios.deployment_target = '7.0'

  s.subspec 'Source' do |source| 
    source.source_files = 'Classes/**/*'
    source.requires_arc = true
  end

  s.subspec 'Binary' do |binary|
    binary.vendored_libraries = 'libDLLHTTPRequest.a'
    binary.ios.framework = 'MobileCoreServices', 'CoreGraphics', 'Security', 'SystemConfiguration'
  end

end
