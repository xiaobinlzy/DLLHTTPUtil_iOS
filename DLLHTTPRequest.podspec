#
# Be sure to run `pod lib lint DLLHTTPRequest.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DLLHTTPRequest'
  s.version          = '0.1.2'
  s.summary          = '网络请求中间层'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
网络请求中间层，底层实现采用AFNetworking。
                       DESC

  s.homepage         = 'http://10.0.0.236/iOS/DLLHTTPRequest/'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'xiaobinlzy' => 'xiaobinlzy@163.com' }
  s.source           = { :git => 'http://10.0.0.236/iOS/DLLHTTPRequest.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'DLLHTTPRequest/Classes/**/*'
  s.public_header_files = 'DLLHTTPRequest/Classes/**/*.h'

  s.requires_arc = true
  s.dependency 'AFNetworking'
  
  # s.resource_bundles = {
  #   'DLLHTTPRequest' => ['DLLHTTPRequest/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
