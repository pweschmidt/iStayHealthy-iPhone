//
//  KeychainHandler.h
//  TestKeyChain
//
// This code is taken from the wonderful tutorial edited by Ray Wenderlich
// http://www.raywenderlich.com/6475/basic-security-in-ios-5-tutorial-part-1
//  Created by Peter Schmidt on 21/02/2013.
//  Copyright (c) 2013 Peter Schmidt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Security/Security.h>
#import <CommonCrypto/CommonHMAC.h>
#import "Constants.h"

@interface KeychainHandler : NSObject
// Generic exposed method to search the keychain for a given value. Limit one result per search.
+ (NSData *)searchKeychainCopyMatchingIdentifier:(NSString *)identifier;

// Calls searchKeychainCopyMatchingIdentifier: and converts to a string value.
+ (NSString *)keychainStringFromMatchingIdentifier:(NSString *)identifier;

// Simple method to compare a passed in hash value with what is stored in the keychain.
// Optionally, we could adjust this method to take in the keychain key to look up the value.
+ (BOOL)compareKeychainValueForMatchingPIN:(NSInteger)pinHash;

// Default initializer to store a value in the keychain.
// Associated properties are handled for you - setting Data Protection Access, Company Identifer (to uniquely identify string, etc).
+ (BOOL)createKeychainValue:(NSString *)value forIdentifier:(NSString *)identifier;

// Updates a value in the keychain. If you try to set the value with createKeychainValue: and it already exists,
// this method is called instead to update the value in place.
+ (BOOL)updateKeychainValue:(NSString *)value forIdentifier:(NSString *)identifier;

// Delete a value in the keychain.
+ (void)deleteItemFromKeychainWithIdentifier:(NSString *)identifier;

// Generates an SHA256 (much more secure than MD5) hash.
+ (NSString *)securedSHA256DigestHashForPIN:(NSUInteger)pinHash;
+ (NSString *)computeSHA256DigestForString:(NSString *)input;

+ (void)resetPasswordAndFlags;
@end
