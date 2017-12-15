//
//  CGYBaseViewController.m
//  test
//
//  Created by Peter on 17/12/14.
//  Copyright © 2017年 PER. All rights reserved.
//

#import "CGYBaseViewController.h"
#import "Request.h"

@interface CGYBaseViewController ()

@end

@implementation CGYBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)click:(UIButton *)sender {
    NSString *url = @"http://appmgr.jwoquxoc.com/frontApi/getAboutUs";
    NSDictionary *csbdDict = @{@"appid":@"bcc10"};
//    [Request requestAsyncRetryEnableAndCallBackInMainWithName:url httpType:POST param:csbdDict retryCount:3 progress:nil success:^(NSURLSessionDataTask *task, NSDictionary *dic) {
//        NSLog(@"%@",[NSThread currentThread]);
//    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//        NSLog(@"%@",[NSThread currentThread]);
//    }];
//    [Request requestAsyncAndCallBackInMainWithName:url httpType:POST param:csbdDict progress:nil success:^(NSURLSessionDataTask *task, NSDictionary *dic) {
//        NSLog(@"%@",[NSThread currentThread]);
//    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//        NSLog(@"%@",[NSThread currentThread]);
//    }];
    NSLog(@"%@",[NSThread currentThread]);
    [Request requestSyncAndCallBackInCurrentWithName:url httpType:POST param:csbdDict success:^(NSURLSessionDataTask *task, NSDictionary *dic) {
        NSLog(@"%@",[NSThread currentThread]);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@",[NSThread currentThread]);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
