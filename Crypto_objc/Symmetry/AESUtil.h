//
//  AES256Util.h
//  ObjectiveC
//
//  Created by Dio Brand on 2022/11/12.
//  Copyright © 2022 my. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AESUtil : NSObject

+(NSData *)encryptData:(NSData *)data withKey:(NSData *)key iv:(NSString *)IV;
+(NSData *)decryptData:(NSData *)data withKey:(NSData *)key iv:(NSString *)IV;

@end

NS_ASSUME_NONNULL_END
