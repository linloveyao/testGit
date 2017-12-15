//
//  ImageUpLoader.h
//  test
//
//  Created by CGY on 17/12/14.
//  Copyright © 2017年 CGY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageUpLoader : NSObject
@property (nonatomic, strong) NSMutableDictionary *successUploadImageAssetDict;//保存已经上传成功的图片的url和asset(key:asset  value:url)
@property (nonatomic, strong) NSMutableDictionary *uploadResultDic;


+ (instancetype)sharedInstance;

- (void)startUploadWithImagesArray:(NSArray *)imagesArray
                        splitCount:(NSUInteger)count
                       withSucceed:(void(^)(NSArray *locateUrlStrings))succeed
                           failure:(void(^)(NSError *error))failure;



- (void)startUploadWithImagesArray:(NSArray *)imagesArray
                ImagesPHAssetArray:(NSArray *)imagesPHAssetArray
                        splitCount:(NSUInteger)count
                       withSucceed:(void(^)(NSArray *locateUrlStrings))succeed
                           failure:(void(^)(NSError *error))failure;
@end
