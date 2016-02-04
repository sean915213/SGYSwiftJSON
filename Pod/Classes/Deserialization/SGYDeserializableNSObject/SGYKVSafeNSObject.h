
//
//  SGYDeserializableNSObject.h
//  SGYSwiftJSON
//
//  Created by Sean Young on 9/17/15.
//  Copyright © 2015 Sean Young. All rights reserved.
//
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
extern NSString* const SGYKVSafeErrorDomain;
extern int const SGYKVSafeErrorSetValueExceptionCode;
extern NSString* const SGYKVSafeErrorUserInfoExceptionKey;
NS_ASSUME_NONNULL_END

@interface NSObject (SGYKVSafeNSObject)

-(void)trySetValue:(nullable id)value forKey:(nonnull NSString*)key error:(NSError* _Nullable * _Nullable)error;

@end
