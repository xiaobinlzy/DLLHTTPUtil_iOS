//
//  ViewController.m
//  DLLHTTPRequest-Test
//
//  Created by DLL on 2016/12/8.
//  Copyright © 2016年 xiaobinlzy. All rights reserved.
//

#import "ViewController.h"
#import <DLLHTTPRequest/DLLHTTPRequest.h>
#import <objc/runtime.h>
#import <AFNetworking/AFNetworking.h>

@interface ViewController ()

@end

@implementation ViewController {
    UIButton *_button;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _button = [UIButton buttonWithType:UIButtonTypeSystem];
    _button.frame = CGRectMake(100, 100, 60, 30);
    [_button setTitle:@"button" forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
}

- (void)clickButton:(id)sender {
#if 0
    DLLHTTPRequest *request = [DLLHTTPRequest requestWithURLString:@"https://m.baidu.com"];
    [request startGetRequestWithCallback:^(DLLHTTPRequest *request, NSString *responseString, NSError *error) {
        NSLog(@"%@", responseString);
    }];
#else
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    __weak AFHTTPSessionManager * weakManager = manager;
    [manager GET:@"https://m.baidu.com" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [weakManager invalidateSessionCancelingTasks:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [weakManager invalidateSessionCancelingTasks:YES];
    }];
#endif
}

@end

@interface NSURLSession (LeakCheck)

@end

@implementation NSURLSession (LeakCheck)
+ (void)load {
    SEL deallocSel = NSSelectorFromString(@"dealloc");
    Method dealloc = class_getInstanceMethod(self, deallocSel);
    Method lc_dealloc = class_getInstanceMethod(self, @selector(lc_dealloc));
    class_addMethod(self, deallocSel, method_getImplementation(dealloc), method_getTypeEncoding(dealloc));
    dealloc = class_getInstanceMethod(self, deallocSel);
    method_exchangeImplementations(dealloc, lc_dealloc);
}

- (void)lc_dealloc {
    [self lc_dealloc];
}

@end
