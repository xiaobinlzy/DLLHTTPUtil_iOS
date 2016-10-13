#
#  Be sure to run `pod spec lint DLLHTTPRequest.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "DLLHTTPRequest"
  s.version      = "0.1.0"
  s.summary      = "网络请求中间层"

  s.description  = <<-DESC
  网络请求中间层，底层实现采用AFNetworking。
                   DESC

  s.homepage     = "http://10.0.0.236/lizhongyu/DLLHTTPRequest/"

  s.license      = "MIT"

  s.author             = { "xiaobinlzy" => "xiaobinlzy@163.com" }

  s.platform     = :ios
  s.platform     = :ios, "7.0"


  s.source       = { :git => "http://10.0.0.236/lizhongyu/DLLHTTPRequest.git", :tag => "#{s.version}" }


  s.source_files  = "Classes", "DLLHTTPRequest/**/*.{h,m}"
  s.exclude_files = "Classes/Exclude"

  s.public_header_files = "DLLHTTPRequest/**/*.h"



   s.framework  = "UIKit"


  s.requires_arc = true

  s.dependency "AFNetworking"

end
