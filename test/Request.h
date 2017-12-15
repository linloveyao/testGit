//
//  Request.h
//  KidsTC
//
//  Created by CGY on 16/7/10.
//  Copyright © 2016年 CGY. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^Progress)(NSProgress * progress);
typedef void (^SuccessBlock)(NSURLSessionDataTask *task, NSDictionary *dic);
typedef void (^FailureBlock)(NSURLSessionDataTask *task, NSError *error);
//请求类型
typedef NS_ENUM(NSInteger, HttpType) {
    GET = 1,
    POST,
};
@interface Request : NSObject

#pragma mark  =========== 异步请求，结果在当主线程回调 ===========
/**
 *  异步请求，结果在主线程回调
 *
 *  @param name     请求别名
 *  @param httpType 请求类型
 *  @param param    请求参数
 *  @param progress 响应进度
 *  @param success  成功 在主线程回调
 *  @param failure  失败 在主线程回调
 */
+ (void)requestAsyncAndCallBackInMainWithName:(NSString *)name
                                     httpType:(HttpType)httpType
                                        param:(NSDictionary *)param
                                     progress:(Progress)progress
                                      success:(SuccessBlock)success
                                      failure:(FailureBlock)failure;

#pragma mark  =========== 异步请求，结果在主线程回调，设置重试次数之后，请求失败可再次请求 ===========
/**
 * 异步请求，结果在主线程回调，设置重试次数之后，请求失败可再次请求
 *
 * @param name          接口别名
 * @param httpType      请求类型
 * @param param         参数
 * @param retryCount    重试次数
 * @param progress      进度
 * @param success       成功回调
 * @param failure       失败回调
 */
+ (NSURLSessionDataTask *)requestAsyncRetryEnableAndCallBackInMainWithName:(NSString *)name
                                                                  httpType:(HttpType)httpType
                                                                     param:(NSDictionary *)param
                                                                retryCount:(NSInteger)retryCount
                                                                  progress:(Progress)progress
                                                                   success:(SuccessBlock)success
                                                                   failure:(FailureBlock)failure;


#pragma mark  =========== 异步请求，结果在子线程回调 ===========
/**
 *  异步请求，结果在子线程回调
 *
 *  @param name     请求别名
 *  @param httpType 请求类型
 *  @param param    请求参数
 *  @param progress 响应进度
 *  @param success  成功 在子线程回调
 *  @param failure  失败 在子线程回调
 */
+ (void)requestAsyncAndCallBackInChildWithName:(NSString *)name
                                      httpType:(HttpType)httpType
                                         param:(NSDictionary *)param
                                      progress:(Progress)progress
                                       success:(SuccessBlock)success
                                       failure:(FailureBlock)failure;


#pragma mark  ===========  同步请求，结果在当前线程回调 ===========
/**
 *  同步请求，结果在当前线程回调
 *
 *  @param name     请求别名
 *  @param httpType 请求类型
 *  @param param    请求参数
 *  @param success  成功 在当前线程回调
 *  @param failure  失败 在当前线程回调
 */
+ (void)requestSyncAndCallBackInCurrentWithName:(NSString *)name
                                       httpType:(HttpType)httpType
                                          param:(NSDictionary *)param
                                        success:(SuccessBlock)success
                                        failure:(FailureBlock)failure;

#pragma mark  ===========  专门用作检查App版本跟新，结果在主线程回调 ===========
/**
 *  专门用作检查App版本跟新，结果在主线程回调
 *
 *  @param name     请求别名
 *  @param httpType 请求类型
 *  @param param    请求参数
 *  @param progress 响应进度
 *  @param success  成功 在主线程回调
 *  @param failure  失败 在主线程回调
 */
+ (void)checkVersionWithName:(NSString *)name
                    httpType:(HttpType)httpType
                       param:(NSDictionary *)param
                    progress:(Progress)progress
                     success:(SuccessBlock)success
                     failure:(FailureBlock)failure;
 
#pragma mark  ===========  下载图片，结果在主线程回调 ===========
/**
 *  下载图片，结果在主线程回调
 *
 *  @param urlStr  图片地址
 *  @param success 成功 主线程回调
 *  @param failure 失败 主线程回调
 */
+ (void)downloadImgWithUrlStr:(NSString *)urlStr
                     success:(void (^)(NSURLSessionDataTask *task,NSData *data))success
                     failure:(void (^)(NSURLSessionDataTask *task,NSError *error))failure;
@end
