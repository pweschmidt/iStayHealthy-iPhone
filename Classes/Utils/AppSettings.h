//
//  AppSettings.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 02/08/2014.
//
//

#import <Foundation/Foundation.h>

@interface AppSettings : NSObject
+ (AppSettings *)sharedInstance;
//- (BOOL)hasUpdated;
//- (void)disablePasswordForUpdate;
//- (void)resetUpdateSettings;
- (BOOL)hasPasswordEnabled;
//- (NSString *)updateMessage;
- (void)saveUbiquityURL:(NSURL *)ubiquityURL;
- (NSString *)ubiquityContentName;
- (NSString *)versionString;
- (NSString *)buildNumberString;
@end
