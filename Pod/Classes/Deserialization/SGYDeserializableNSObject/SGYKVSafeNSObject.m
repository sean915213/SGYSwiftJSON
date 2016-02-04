//
//  SGYDeserializableNSObject.m
//  SGYSwiftJSON
//
//  Created by Sean Young on 9/17/15.
//  Copyright © 2015 Sean Young. All rights reserved.
//

#import "SGYKVSafeNSObject.h"

NSString* const SGYKVSafeErrorDomain = @"SGYKVSafeNSObject";
int const SGYKVSafeErrorSetValueExceptionCode = 1;
NSString* const SGYKVSafeErrorUserInfoExceptionKey = @"exception";

@implementation NSObject (SGYKVSafeNSObject)

-(void)trySetValue:(id)value forKey:(NSString*)key error:(NSError**)error
{
    // Set value inside try/catch for extra safety
    @try {
        [self setValue:value forKey:key];
    } @catch (NSException* e) {
        *error = [NSError errorWithDomain:SGYKVSafeErrorDomain
                                     code:SGYKVSafeErrorSetValueExceptionCode
                                 userInfo:@{ SGYKVSafeErrorUserInfoExceptionKey: e }];
    }
}

@end
