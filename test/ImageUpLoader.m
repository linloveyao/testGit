//
//  ImageUpLoader.m
//  test
//
//  Created by CGY on 17/12/14.
//  Copyright © 2017年 CGY. All rights reserved.
//

#import "ImageUpLoader.h"
#import <Photos/Photos.h>

@implementation ImageUpLoader
static ImageUpLoader *sharedInstance;
//+ (instancetype)sharedInstance {
//    static dispatch_once_t token = 0;
//    dispatch_once(&token, ^{
//        sharedInstance = [[ImageUpLoader alloc] init];
//    });
//    return sharedInstance;
//}
//- (NSMutableDictionary *)successUploadImageAssetDict
//{
//    if (!_successUploadImageAssetDict) {
//        _successUploadImageAssetDict = [NSMutableDictionary dictionary];
//    }
//    return _successUploadImageAssetDict;
//}
//- (NSMutableDictionary *)uploadResultDic
//{
//    if (!_uploadResultDic) {
//        _uploadResultDic = [NSMutableDictionary dictionary];
//    }
//    return _uploadResultDic;
//}
//- (void)startUploadWithImagesArray:(NSArray *)imagesArray splitCount:(NSUInteger)count withSucceed:(void (^)(NSArray *))succeed failure:(void (^)(NSError *))failure {
//    self.uploadResultDic  = [NSMutableDictionary dictionary];
//    NSUInteger totalCount = imagesArray.count;
//    for (int i = 0; i<totalCount; i++) {
//        UIImage *image = imagesArray[i];
//        [self startUploadWithImage:image splitCount:count succeed:^(NSString *locateUrlString) {
//            if ([locateUrlString isNotNull]) {
//                [self.uploadResultDic setObject:locateUrlString forKey:@(i)];
//                NSUInteger dicCount = self.uploadResultDic.count;
//                if (dicCount == totalCount) {
//                    if (succeed) succeed([self getUploadResultArray]);
//                }
//            } else {
//                if (failure) {
//                    NSError *error = [NSError errorWithDomain:@"Image upload" code:-100001 userInfo:[NSDictionary dictionaryWithObject:@"Response not valid." forKey:kErrMsgKey]];
//                    failure(error);
//                }
//            }
//        } failure:^(NSError *error) {
//            if (failure) failure(error);
//        }];
//    }
//}
//
//- (void)startUploadWithImagesArray:(NSArray *)imagesArray
//                ImagesPHAssetArray:(NSArray *)imagesPHAssetArray
//                        splitCount:(NSUInteger)count
//                       withSucceed:(void(^)(NSArray *locateUrlStrings))succeed
//                           failure:(void(^)(NSError *error))failure
//{
//    //获取所有图片的唯一标识符保存在一个数组里面
//    NSMutableArray *selectedAssetArr = [NSMutableArray array];
//    for (PHAsset *asset in imagesPHAssetArray) {
//        [selectedAssetArr addObject:asset.localIdentifier];
//    }
//    
//    NSUInteger totalCount = imagesArray.count;
//    for (int i = 0; i<totalCount; i++) {
//        UIImage *image = imagesArray[i];
//        
//        //在已上传的图片里面查看是否存在
//        NSString *imageAsset = selectedAssetArr[i];
//        BOOL isExsit = NO;
//        for (NSString *str in [self.successUploadImageAssetDict allKeys]) {
//            if ([str isEqualToString:imageAsset]) {
//                isExsit = YES;
//            }
//        }
//        
//        if (!isExsit) {
//            [self startUploadWithImage:image splitCount:count succeed:^(NSString *locateUrlString) {
//                if ([locateUrlString isNotNull]) {
//                    [self.uploadResultDic setObject:locateUrlString forKey:@(i)];
//                    
//                    [self.successUploadImageAssetDict setObject:locateUrlString forKey:imageAsset];
//                    
//                    NSUInteger dicCount = self.uploadResultDic.count;
//                    if (dicCount == totalCount) {
//                        if (succeed) succeed([self getUploadResultArray]);
//                    }
//                } else {
//                    if (failure) {
//                        NSError *error = [NSError errorWithDomain:@"Image upload" code:-100001 userInfo:[NSDictionary dictionaryWithObject:@"Response not valid." forKey:kErrMsgKey]];
//                        failure(error);
//                    }
//                }
//            } failure:^(NSError *error) {
//                if (failure) failure(error);
//            }];
//        }else{
//            //从已成功上传的图片中找到该asset所在的图片放到该图片对应的位置
//            [self.uploadResultDic setObject:[self.successUploadImageAssetDict objectForKey:imageAsset] forKey:@(i)];
//            NSUInteger dicCount = self.uploadResultDic.count;
//            if (dicCount == totalCount) {
//                if (succeed) succeed([self getUploadResultArray]);
//            }
//        }
//    }
//    
//}
//#pragma mark Private methods
//
//- (void)startUploadWithImage:(UIImage *)image splitCount:(NSUInteger)count succeed:(void (^)(NSString *))succeed failure:(void (^)(NSError *))failure {
//    NSData *data = UIImageJPEGRepresentation(image, 0.0);
//    if (!data) return;
//    NSString *dataString = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
//    if (![dataString isNotNull]) return;
//    NSDictionary *param = @{@"fileStr" : dataString,
//                            @"suffix"  : @"JPEG",
//                            @"count"   : @(count)};
//    
//    [Request tc_mainThreadAsyncWithName:FILE_UPLOAD param:param  retryCount:0 progress:nil success:^(NSURLSessionDataTask *task, NSDictionary *dic) {
//        
//        NSString *location = [self getUploadLocationWithResponse:dic];
//        if (succeed) succeed(location);
//    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//        if (failure) failure(error);
//    }];
//}
//
//- (NSString *)getUploadLocationWithResponse:(NSDictionary *)respData {
//    NSString *dataString = [respData objectForKey:@"data"];
//    return [dataString isNotNull]?dataString:nil;
//}
//
//- (NSArray *)getUploadResultArray {
//    if ((!_uploadResultDic) || (_uploadResultDic.count == 0)) {
//        return nil;
//    }
//    NSArray *allKeys = [self.uploadResultDic allKeys];
//    allKeys = [allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//        NSNumber *key1 = obj1;
//        NSNumber *key2 = obj2;
//        return [key1 compare:key2];
//    }];
//    
//    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
//    for (NSNumber *key in allKeys) {
//        NSString *result = [self.uploadResultDic objectForKey:key];
//        [tempArray addObject:result];
//    }
//    
//    return [NSArray arrayWithArray:tempArray];
//}
//
//- (BOOL)isNotNull{
//    
//    if ([self isKindOfClass:[NSNull class]]) {
//        return false;
//    }
//    
//    return (self &&
//            [self isKindOfClass:[NSString class]] &&
//            self.length>0 &&
//            ![@"null" isEqualToString:self] &&
//            ![@"(null)" isEqualToString:self] &&
//            ![@"<null>" isEqualToString:self]);
//}
@end
