//
//  SGYKVCSafeNSObject.m
//  SGYKVCSafeNSObject
//
//  Created by Sean Young on 9/17/15.
//  Copyright © 2015 Sean Young. All rights reserved.
//

#import "SGYKVCSafeNSObject.h"

NSString* const SGYKVCSafeErrorDomain = @"SGYKVCSafeNSObject";
NSString* const SGYKVCSafeErrorUserInfoExceptionKey = @"exception";

int const SGYKVCSafeErrorSetValueExceptionCode = 1;
int const SGYKVCSafeErrorGetValueExceptionCode = 2;

@implementation NSObject (SGYKVCSafeNSObject)

-(id)valueForKey:(NSString*)key error:(NSError**)error
{
    @try {
        return [self valueForKey:key];
    } @catch (NSException* e) {
        if (error == nil) return nil;
        // Haven't determined why yet but attempting to pack exception into a dictionary in this method causes a BAD_ACCESS_EXCEPTION (regardless of nil check)
        *error = [NSError errorWithDomain:SGYKVCSafeErrorDomain
                                     code:SGYKVCSafeErrorGetValueExceptionCode
                                 userInfo:nil];
    }
}

-(id)valueForKeyPath:(NSString*)keyPath error:(NSError**)error
{
    @try {
        return [self valueForKey:keyPath];
    } @catch (NSException* e) {
        if (error == nil) return nil;
        // Haven't determined why yet but attempting to pack exception into a dictionary in this method causes a BAD_ACCESS_EXCEPTION (regardless of nil check)
        *error = [NSError errorWithDomain:SGYKVCSafeErrorDomain
                                     code:SGYKVCSafeErrorGetValueExceptionCode
                                 userInfo:nil];
    }
}

-(void)setValue:(id)value forKey:(NSString*)key error:(NSError**)error
{
    @try {
        [self setValue:value forKey:key];
    } @catch (NSException* e) {
        if (error == nil) return;
        *error = [NSError errorWithDomain:SGYKVCSafeErrorDomain
                                     code:SGYKVCSafeErrorSetValueExceptionCode
                                 userInfo:@{ SGYKVCSafeErrorUserInfoExceptionKey: e }];
    }
}

-(void)setValue:(id)value forKeyPath:(NSString *)keyPath error:(NSError *__autoreleasing  _Nullable *)error
{
    @try {
        [self setValue:value forKeyPath:keyPath];
    } @catch (NSException* e) {
        if (error == nil) return;
        *error = [NSError errorWithDomain:SGYKVCSafeErrorDomain
                                     code:SGYKVCSafeErrorSetValueExceptionCode
                                 userInfo:@{ SGYKVCSafeErrorUserInfoExceptionKey: e }];
    }
}

@end
