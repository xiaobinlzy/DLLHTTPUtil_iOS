Pod::Spec.new do |s|
  s.name = 'DLLHTTPRequest'
  s.version = '0.1.2'
  s.summary = '网络请求中间层'
  s.license = {"type"=>"MIT", "file"=>"LICENSE"}
  s.authors = {"xiaobinlzy"=>"xiaobinlzy@163.com"}
  s.homepage = 'http://10.0.0.236/iOS/DLLHTTPRequest/'
  s.description = '网络请求中间层，底层实现采用AFNetworking。'
  s.requires_arc = true
  s.source = { :git => 'http://10.0.0.236/iOS/DLLHTTPRequest.git', :tag => s.version.to_s }

  s.ios.deployment_target    = '8.0'
  s.ios.preserve_paths       = 'ios/DLLHTTPRequest.framework'
  s.ios.public_header_files  = 'ios/DLLHTTPRequest.framework/Versions/A/Headers/*.h'
  s.ios.resource             = 'ios/DLLHTTPRequest.framework/Versions/A/Resources/**/*'
  s.ios.vendored_frameworks  = 'ios/DLLHTTPRequest.framework'
end
