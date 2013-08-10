//
//  CoreDataUtils.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/08/2013.
//
//

#import <Foundation/Foundation.h>

@interface CoreDataUtils : NSObject
/**
 @return options for a store local to the device
 */
+ (NSDictionary *)localStoreOptions;

/**
 @return dictionary containing iCloud store options. Returns nil if iCloud
 is disabled for device/user
 */
+ (NSDictionary *)iCloudStoreOptions;

+ (void)archiveUbiquityToken:(id)token;

+ (id)ubiquityTokenFromArchive;

+ (void)dropUbiquityToken;
@end
