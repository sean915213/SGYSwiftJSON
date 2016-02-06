
//
//  SGYKVCSafeNSObject.h
//  SGYKVCSafeNSObject
//
//  Created by Sean Young on 9/17/15.
//  Copyright © 2015 Sean Young. All rights reserved.
//
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
extern NSString* const SGYKVCSafeErrorDomain;
extern NSString* const SGYKVCSafeErrorUserInfoExceptionKey;
extern int const SGYKVCSafeErrorSetValueExceptionCode;
extern int const SGYKVCSafeErrorGetValueExceptionCode;
NS_ASSUME_NONNULL_END

/**
 *  Extends NSObject's key value coding methods to catch exceptions and populate NSError objects.
 */
@interface NSObject (SGYKVCSafeNSObject)

/**
 *  Wraps valueForKey: in try/catch blocks in order to return any exception as an NSError object.
 *
 *  @param key   The key.
 *  @param error An `NSError` object populated with the associated domain and code if an exception is thrown.
 *
 *  @return The key's associated value or nil if an exception was thrown.
 */
-(nullable id)valueForKey:(nonnull NSString*)key error:(NSError* _Nullable * _Nullable)error;

/**
 *  Wraps valueForKey: in try/catch blocks in order to return any exception as an NSError object.
 *
 *  @param keyPath The key path.
 *  @param error   An `NSError` object populated with the associated domain and code if an exception is thrown.
 *
 *  @return The key path's associated value or nil if an exception was thrown.
 */
-(nullable id)valueForKeyPath:(nonnull NSString*)keyPath error:(NSError* _Nullable * _Nullable)error;

/**
 *  Wraps setValue:forKey: in try/catch blocks in order to return any exception as an NSError object.
 *
 *  @param value The value to set.
 *  @param key   The key.
 *  @param error An `NSError` object populated with the associated error domain, code, and userInfo dictionary populated with the caught exception.
 */
-(void)setValue:(nullable id)value forKey:(nonnull NSString*)key error:(NSError* _Nullable * _Nullable)error;

/**
 *  Wraps setValue:forKeyPath: in try/catch blocks in order to return any exception as an NSError object.
 *
 *  @param value The value to set.
 *  @param key   The key path.
 *  @param error An `NSError` object populated with the associated error domain, code, and userInfo dictionary populated with the caught exception.
 */
-(void)setValue:(nullable id)value forKeyPath:(nonnull NSString*)key error:(NSError* _Nullable * _Nullable)error;

@end
