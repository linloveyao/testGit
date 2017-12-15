//
//  Request.m
//  KidsTC
//
//  Created by CGY on 16/7/10.
//  Copyright © 2016年 CGY. All rights reserved.
//

#import "Request.h"
#import "AFNetworking.h"

static Request *_requestManager;

@interface Request ()
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@property (nonatomic, strong) AFHTTPSessionManager *downloadSessionManager; 
@end

@implementation Request

+ (Request *)shareRequestManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _requestManager = [[self alloc]init];
        _requestManager.sessionManager = [AFHTTPSessionManager manager];
        _requestManager.sessionManager.responseSerializer =[AFHTTPResponseSerializer serializer];
        _requestManager.sessionManager.requestSerializer.timeoutInterval = 6;
        _requestManager.downloadSessionManager = [AFHTTPSessionManager manager];
        _requestManager.downloadSessionManager.responseSerializer =[AFHTTPResponseSerializer serializer];
    });
    return _requestManager;
}
#pragma mark  =========== 异步请求，结果在主线程回调 ===========
+ (void)requestAsyncAndCallBackInMainWithName:(NSString *)name
                                     httpType:(HttpType)httpType
                                        param:(NSDictionary *)param
                                     progress:(Progress)progress
                                      success:(SuccessBlock)success
                                      failure:(FailureBlock)failure
{
    AFHTTPSessionManager *manager = [self shareRequestManager].sessionManager;
    
    switch (httpType) {
        case GET:
        {
            [manager GET:name parameters:param progress:^(NSProgress * _Nonnull downloadProgress) {
                if (progress) progress(downloadProgress);
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self responseSuccessWithTask:task responseObject:responseObject success:success failure:failure];
                });
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self responseFailureWithName:name httpType:httpType param:param Task:task error:error failure:failure];
                    
                });
            }];
        }
            break;
        case POST:
        {
            [manager POST:name parameters:param progress:^(NSProgress * _Nonnull uploadProgress) {
                if (progress) progress(uploadProgress);
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self responseSuccessWithTask:task responseObject:responseObject success:success failure:failure];
                    
                });
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self responseFailureWithName:name httpType:httpType param:param Task:task error:error failure:failure];
                    
                });
            }];
        }
            break;
            default:
        {
            if (failure) failure(nil,nil);
            return ;
        }
            break;
    }
}

#pragma mark  =========== 异步请求，结果在主线程回调，设置重试次数之后，请求失败可再次请求 ===========
+ (NSURLSessionDataTask *)requestAsyncRetryEnableAndCallBackInMainWithName:(NSString *)name
                                                                  httpType:(HttpType)httpType
                                                                     param:(NSDictionary *)param
                                                                retryCount:(NSInteger)retryCount
                                                                  progress:(Progress)progress
                                                                   success:(SuccessBlock)success
                                                                   failure:(FailureBlock)failure
{
    AFHTTPSessionManager *manager = [self shareRequestManager].sessionManager;
    
    switch (httpType) {
        case GET:
        {
            return [manager GET:name parameters:param progress:^(NSProgress * _Nonnull downloadProgress) {
                if (progress) progress(downloadProgress);
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self responseSuccessWithTask:task responseObject:responseObject success:success failure:failure];
                });
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self responseFailureWithName:name httpType:httpType param:param retryCount:retryCount progress:progress task:task error:error success:success failure:failure];
                });
            }];
        }
            break;
        case POST:
        {
            return [manager POST:name parameters:param progress:^(NSProgress * _Nonnull uploadProgress) {
                if (progress) progress(uploadProgress);
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self responseSuccessWithTask:task responseObject:responseObject success:success failure:failure];
                    
                });
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self responseFailureWithName:name httpType:httpType param:param retryCount:retryCount progress:progress task:task error:error success:success failure:failure];
                });
            }];
        }
            break;
        default:
        {
            if (failure) failure(nil,nil);
            return nil;
        }
            break;
    }
}
/** 响应失败  */
+(void)responseFailureWithName:(NSString *)name
                      httpType:(HttpType)httpType
                         param:(NSDictionary *)param
                    retryCount:(NSInteger)retryCount
                      progress:(Progress)progress
                          task:(NSURLSessionDataTask *)task
                         error:(NSError *)error
                       success:(SuccessBlock)success
                       failure:(FailureBlock)failure
{
    if (retryCount > 0) {
        retryCount --;
        [self requestAsyncRetryEnableAndCallBackInMainWithName:name httpType:httpType param:param retryCount:retryCount progress:progress success:success failure:failure];
        return;
    }
    NSLog(@"\n==================   响应失败   ==================\n接口名称:%@\n请求方式:%@\n参数字典:%@\n错误报文:%@\n==================   报文结束   ==================\n",name,httpType == 1?@"GET":@"POST",param,error);
    if (failure) failure(task,error);
//    interfaceItem.end = [[NSDate date] timeIntervalSince1970];
//    [Request getStatusCodeItem:interfaceItem task:task];
}

#pragma mark  =========== 异步请求，结果在子线程回调 ===========
+ (void)requestAsyncAndCallBackInChildWithName:(NSString *)name
                                      httpType:(HttpType)httpType
                                         param:(NSDictionary *)param
                                      progress:(Progress)progress
                                       success:(SuccessBlock)success
                                       failure:(FailureBlock)failure
{
    AFHTTPSessionManager *manager = [self shareRequestManager].sessionManager;
    
    switch (httpType) {
        case GET:
        {
            [manager GET:name parameters:param progress:^(NSProgress * _Nonnull downloadProgress) {
                if (progress) progress(downloadProgress);
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self responseSuccessWithTask:task responseObject:responseObject success:success failure:failure];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self responseFailureWithName:name httpType:httpType param:param Task:task error:error failure:failure];
            }];
        }
            break;
        case POST:
        {
            [manager POST:name parameters:param progress:^(NSProgress * _Nonnull uploadProgress) {
                if (progress) progress(uploadProgress);
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self responseSuccessWithTask:task responseObject:responseObject success:success failure:failure];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self responseFailureWithName:name httpType:httpType param:param Task:task error:error failure:failure];
            }];
        }
            break;
        default:
        {
            if (failure) failure(nil,nil);
            return ;
        }
            break;
    }
}

#pragma mark  ===========  同步请求，结果在当前线程回调 ===========
+ (void)requestSyncAndCallBackInCurrentWithName:(NSString *)name
                                       httpType:(HttpType)httpType
                                          param:(NSDictionary *)param
                                        success:(SuccessBlock)success
                                        failure:(FailureBlock)failure
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0); //创建信号量
    NSURLSession *session = [NSURLSession sharedSession];
    NSString *urlStr = nil;
    NSString *HTTPMethod = nil;
    NSData *HTTPBody = nil;
    switch (httpType) {
        case GET:
        {
            urlStr = [NSString stringWithFormat:@"%@%@",name,[self paramString:param]];
            HTTPMethod = @"GET";
        }
            break;
        case POST:
        {
            urlStr = name;
            HTTPMethod = @"POST";
            HTTPBody = [[self paramString:param] dataUsingEncoding:NSUTF8StringEncoding];
        }
            break;
        default:
        {
            if (failure) failure(nil,nil);
            return;
        }
            break;
    }
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = HTTPMethod;
    request.HTTPBody = HTTPBody;
    __block NSURLSessionDataTask *task;
    task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            [self responseSuccessWithTask:task
                                    responseObject:data
                                           success:success
                                           failure:failure];
        }else{
            [self responseFailureWithName:name httpType:httpType param:param Task:task error:error failure:failure];
        }
        dispatch_semaphore_signal(semaphore);   //发送信号
    }];
    [task resume];
    dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER);//等待
}

/**
 *  响应成功
 */
+(void)responseSuccessWithTask:(NSURLSessionDataTask *)task
                responseObject:(id)responseObject
                       success:(SuccessBlock)success
                       failure:(FailureBlock)failure

{
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
    if ([dic[@"errno"] respondsToSelector:@selector(integerValue)]) {
        NSInteger errNo = [dic[@"errno"] integerValue];
        if (errNo == 0) {//如果errNo为0，则为请求成功
            NSLog(@"响应成功-success-:响应报文:%@\n",dic);
            if (success) success(task,dic);
        }else{//否则全部按照请求失败处理
            NSError *error = [NSError errorWithDomain:@"Http request" code:errNo userInfo:dic];
            NSLog(@"响应成功-(但errno非0，按照请求失败来处理)-failure-\n响应报文:%@\n",error);
            if (failure) failure(task,error);
        }
    }else{
        NSError *error = [NSError errorWithDomain:@"Http request" code:-1 userInfo:dic];
        NSLog(@"响应成功-(但errno不是int类型，按照请求失败来处理)-failure-\n响应报文:%@\n",error);
        if (failure) failure(task,error);
    }
//    interfaceItem.end = [[NSDate date] timeIntervalSince1970];
//    [Request getStatusCodeItem:interfaceItem task:task];
}
/**
 *  响应失败
 */
+(void)responseFailureWithName:(NSString *)name
                      httpType:(HttpType)httpType
                         param:(NSDictionary *)param
                          Task:(NSURLSessionDataTask *)task
                         error:(NSError *)error
                       failure:(FailureBlock)failure
{
    NSLog(@"\n==================   响应失败   ==================\n接口名称:%@\n请求方式:%@\n参数字典:%@\n错误报文:%@\n==================   报文结束   ==================\n",name,httpType == 1?@"GET":@"POST",param,error);
    if (failure) failure(task,error);
//    interfaceItem.end = [[NSDate date] timeIntervalSince1970];
//    [Request getStatusCodeItem:interfaceItem task:task];
}

#pragma mark  ===========  专门用作检查App版本跟新，结果在主线程回调 ===========
+ (void)checkVersionWithName:(NSString *)name
                    httpType:(HttpType)httpType
                       param:(NSDictionary *)param
                    progress:(Progress)progress
                     success:(SuccessBlock)success
                     failure:(FailureBlock)failure
{
    AFHTTPSessionManager *manager = [self shareRequestManager].sessionManager;
    switch (httpType) {
        case GET:
        {
            [manager GET:name parameters:param progress:^(NSProgress * _Nonnull downloadProgress) {
                if (progress) progress(downloadProgress);
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self checkVersionSuccessWithTask:task responseObject:responseObject success:success failure:failure];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self checkVersionFailureWithTask:task error:error failure:failure];
            }];
        }
            break;
        case POST:
        {
            [manager POST:name parameters:param progress:^(NSProgress * _Nonnull uploadProgress) {
                if (progress) progress(uploadProgress);
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self checkVersionSuccessWithTask:task responseObject:responseObject success:success failure:failure];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self checkVersionFailureWithTask:task error:error failure:failure];
            }];
        }
            break;
        default:
        {
            if (failure) failure(nil,nil);
            return;
        }
            break;
    }
}

/**
 *  检查App版本跟新响应成功
 */
+(void)checkVersionSuccessWithTask:(NSURLSessionDataTask *)task
                    responseObject:(id)responseObject
                           success:(SuccessBlock)success
                           failure:(FailureBlock)failure

{
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
    if ([dic[@"Code"] respondsToSelector:@selector(integerValue)]) {
        NSInteger Code = [dic[@"Code"] integerValue];
        if (Code == 0) {//如果errNo为0，则为请求成功
            NSLog(@"响应成功-success-\n响应报文:%@\n",dic);
            if (success) success(task,dic);
        }else{//否则全部按照请求失败处理
            NSError *error = [NSError errorWithDomain:@"Http request" code:Code userInfo:dic];
            NSLog(@"响应成功-(但errno非0，按照请求失败来处理)-failure-\n响应报文:%@\n",error);
            if (failure) failure(task,error);
        }
    }else{
        NSError *error = [NSError errorWithDomain:@"Http request" code:-1 userInfo:dic];
        NSLog(@"响应成功-(但errno不是int类型，按照请求失败来处理)-failure-\n响应报文:%@\n",error);
        if (failure) failure(task,error);
    }
//    interfaceItem.end = [[NSDate date] timeIntervalSince1970];
//    [Request getStatusCodeItem:interfaceItem task:task];
}

/**
 *  检查App版本跟新响应失败
 */
+(void)checkVersionFailureWithTask:(NSURLSessionDataTask *)task
                             error:(NSError *)error
                           failure:(FailureBlock)failure
{
    NSLog(@"响应失败-failure-\n错误报文:%@\n",error);
    if (failure) failure(task,error);
//    interfaceItem.end = [[NSDate date] timeIntervalSince1970];
//    [Request getStatusCodeItem:interfaceItem task:task];
}

#pragma mark  ===========  下载图片，结果在主线程回调 ===========
+ (void)downloadImgWithUrlStr:(NSString *)urlStr
                     success:(void (^)(NSURLSessionDataTask *task,NSData *data))success
                     failure:(void (^)(NSURLSessionDataTask *task,NSError *error))failure
{
    AFHTTPSessionManager *manager = [self shareRequestManager].downloadSessionManager;
    [manager GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) success(task,responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) failure(task,error);
    }];
}
#pragma mark - helpers
+ (NSString *)paramString:(NSDictionary *)parameters{
    if (!parameters || ![parameters isKindOfClass:[NSDictionary class]]) return @"";
    NSMutableString *str = [NSMutableString string];
    NSArray *keys = parameters.allKeys;
    NSUInteger count = keys.count;
    for (int i = 0; i<count; i++) {
        NSString *key = keys[i];
        NSString *value = parameters[key];
        NSMutableString *item = [NSMutableString stringWithFormat:@"&%@=%@",key,value];
        [str appendString:item];
    }
    return str;
}

//static bool canupload = true;
//
//+ (void)getStatusCodeItem:(InterfaceItem *)interfaceItem
//                     task:(NSURLSessionDataTask *)task
//{
//    if(!canupload)return;
//    canupload = false;
//    
//    NSString *urlTag = interfaceItem.name;
//    if (![urlTag isNotNull]) return;
//    
//    NSHTTPURLResponse *responses = (NSHTTPURLResponse *)task.response;
//    NSInteger netCode = responses.statusCode;
//    long long time = (interfaceItem.end - interfaceItem.start)*1000;
//    
//    NSDictionary *allHeaderFields = responses.allHeaderFields;
//    id date = allHeaderFields[@"Date"];
//    id last_Modified = allHeaderFields[@"Last-Modified"];
//    if (date && last_Modified && [date isKindOfClass:[NSDate class]] && [last_Modified isKindOfClass:[NSDate class]]) {
//        NSTimeInterval date_time = [date timeIntervalSince1970];
//        NSTimeInterval last_Modified_time = [last_Modified timeIntervalSince1970];
//        time = (last_Modified_time - date_time)*1000;
//    }
//    
//    NSMutableDictionary *content = [NSMutableDictionary dictionary];
//    [content setObject:@(time) forKey:@"apiCellTime"];
//    NetType netType = [BuryPointManager NetworkStatusTo];
//    [content setObject:@(netType) forKey:@"networkType"];
//    [content setObject:@(netCode) forKey:@"httpStatusCode"];
//    [content setObject:@(2) forKey:@"channel"];
//    if ([urlTag isNotNull]) {
//        [content setObject:urlTag forKey:@"urlTag"];
//    }
//    long long pk = arc4random()%10000000000;
//    NSString *pkMD5String = [NSString stringWithFormat:@"%@",@(pk)].md5String;
//    if ([pkMD5String isNotNull]) {
//        [content setObject:pkMD5String forKey:@"pk"];
//    }
//    
//    NSString *str = [NSString zp_stringWithJsonObj:content];
//    if ([str isNotNull]) {
//        BuryPointModel *model = [BuryPointModel new];
//        model.content = str;
//        DataBaseManager *man = [DataBaseManager shareDataBaseManager];
//        [man request_inset:model successBlock:^(BOOL success) {
//            [man request_not_upload_count:^(NSUInteger count) {
//                if (count<50) return ;
//                [man request_not_upload_allModels:^(NSArray<BuryPointModel *> *models) {
//                    if (models.count<1) return;
//                    NSMutableArray *ary = [NSMutableArray array];
//                    [models enumerateObjectsUsingBlock:^(BuryPointModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                        if ([obj.content isNotNull]) {
//                            NSData *data = [obj.content dataUsingEncoding:NSUTF8StringEncoding];
//                            if (data) {
//                                NSError *error_dic = nil;
//                                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error_dic];
//                                if (!error_dic && dic && [dic isKindOfClass:[NSDictionary class]] && dic.count>0) {
//                                    [ary addObject:dic];
//                                }
//                            };
//                        }
//                    }];
//                    NSString *aryStr = [NSString zp_stringWithJsonObj:ary];
//                    if (![aryStr isNotNull]) return;
//                    NSDictionary *param = @{@"reportMsg":aryStr};
//                    [Request startWithName:@"REPORT_API_CELL_TIME" param:param progress:nil success:^(NSURLSessionDataTask *task, NSDictionary *dic) {
//                        canupload = true;
//                        [self deleteRequest_not_upload];
//                    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//                        canupload = true;
//                        [self deleteRequest_not_upload];
//                    }];
//                }];
//            }];
//        }];
//    }
//}

//+ (void)deleteRequest_not_upload {
//    [[DataBaseManager shareDataBaseManager] request_not_upload_allModels_deleteSuccessBlock:^(BOOL success) {
//        if (success) {
//            TCLog(@"request_not_upload_allModels批量删除成功...");
//        }else{
//            TCLog(@"request_not_upload_allModels批量删除失败...");
//        }
//    }];
//}
@end
