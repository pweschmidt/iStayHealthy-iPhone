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
+ (CGRect)frameFromSize:(CGSize)size;
+ (UIActivityIndicatorView *)activityIndicatorViewWithFrame:(CGRect)frame;
+ (NSString *)medListURLFromLocale;
+ (NSString *)generalInfoURLFromLocale;
+ (NSString *)testingInfoURLFromLocale;
+ (NSString *)preventionURLFromLocale;
+ (BOOL)isIPad;
+ (NSDictionary *)calendarDictionary;
+ (NSDateComponents *)dateComponentsForDate:(NSDate *)date;
+ (NSString *)monthForDate:(NSDate *)date;
+ (NSString *)weekDayForDate:(NSDate *)date;
+ (NSString *)imageNameFromMedName:(NSString *)medName;
+ (UIImage *)imageFromMedName:(NSString *)medName;
+ (NSDictionary *)resultsTypeDictionary;
+ (NSDictionary *)resultsTypeWithShortNamesDictionary;
+ (NSDictionary *)colourTypeDictionary;
+ (NSInteger)daysInMonth:(NSInteger)month inYear:(NSInteger)inYear;
+ (NSUInteger)monthsToMonitorFromStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;
+ (NSUInteger)weeksInMonthForDate:(NSDate *)date isStartDate:(BOOL)isStartDate;
+ (NSDateComponents *)fullComponentsFromDay:(NSInteger)day month:(NSInteger)month year:(NSInteger)year;
+ (CGRect)popUpFrameInMainFrame:(CGRect)mainFrame;
+ (UIModalPresentationStyle)modalPresentationStyle;
+ (BOOL)isSimulator;
@end
