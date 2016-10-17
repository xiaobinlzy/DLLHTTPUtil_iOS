# DLLHTTPRequest说明文档
------------

## 说明
DLLHTTPRequest是一个基于当前iOS流行的http框架（目前是ASIHttpRequest和AFNetworking）封装的一套类库，作为http请求中间层，可以自由切换底层所使用的框架，对外部提供统一的API以供调用。这个中间层的目的是为了将业务代码与http框架隔离，这样在http框架更新或者更换的时候，不会对业务代码有任何伤害。
## 使用方法
在Podfile中加入source：

```ruby
source 'http://10.0.0.236/lizhongyu/ChinaHRLibraryPodSpec.git'
```
在Podfile中加入pod:

```ruby
pod 'DLLHTTPRequest'    # HTTP中间层
```

以提交用户反馈的接口为例，代码如下：

```objective-c
//	使用dictionary来存储请求参数       
NSMutableDictionary *params = [NSMutableDictionary dictionary]; 
[params setInstance:comments forKey:@"comments"];
[params setInstance:contact forKey:@"contact"];
[params setInstance:[UIDevice currentDevice].model forKey:@"deviceType"]; 
[params setInstance:[UIDevice currentDevice].systemVersion forKey:@"OSVersion"];

// 创建请求对象
DLLHTTPRequest *request = [DLLHTTPRequest requestWithURLString:@"http://appconfig.chinahr.com/feedback"];
// 设置请求回调
request.callback = ^(DLLHTTPRequest * request, NSString * responseString, NSError * error) {
	// 在这里处理结果回调
};
// 开始POST请求
[request startPostRequest];
```
## 主要类说明
类名 | 说明
--- | ---
DLLHTTPRequest | 网络请求类，通过URL来初始化，可以设置请求参数、请求类型、请求头等属性，超时时长、回调代理和回调block，还可以通过参数来设置请求所使用的底层框架。
DLLHTTPRequestDelegate | DLLHTTPRequest的回调代理，会对请求的生命周期进行监听回调：请求开始，请求结束，请求完成和请求失败。
DLLRequestOperator | 具体使用HTTP框架执行网络请求的抽象类，它提供开始请求和取消请求的抽象方法，也对DLLHTTPRequest进行回调。 DLLHTTPRequest中会根据参数使用工厂方法生成DLLRequestOperator的某个子类来执行网络请求。
DLLASIRequestOperator | DLLRequestOperator的子类之一，它使用ASIHttpRequest来进行网络请求。
DLLAFNetworkingRequestOperator | DLLRequestOperator的子类之一，它使用AFNetworking来进行网络请求。
DLLHTTPResponse | 网络请求返回数据的模型类，包括HTTP状态码、响应数据、响应字符串、响应头等等。

