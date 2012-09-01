//
//  Utilities.h
//  iStayHealthy
//
//  Created by peterschmidt on 31/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
 
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)
#define DEVICE_IS_SIMULATOR                         ([[[UIDevice currentDevice] model] hasSuffix:@"Simulator"])
//NSString *deviceType = [[UIDevice currentDevice]model];
//if ([deviceType hasSuffix:@"Simulator"]) {


@interface Utilities : NSObject
+ (NSString *)GUID;
+ (BOOL)hasFloatingPoint:(NSNumber *)number;
+ (UIImage *)bannerImageFromLocale;
+ (NSString *)urlStringFromLocale;
+ (NSString *)titleFromLocale;
@end