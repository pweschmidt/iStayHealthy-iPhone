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

/**
   @return dictionary containing the iCloud store options with an additional to remove the ubiquity metadata.
   This is so we can migrate the iCloud store to non-iCloud environment if users so wish
 */
+ (NSDictionary *)noiCloudStoreOptions;

/**
   we need to modify the iCloud option so that the Ubiquity path no longer contains '.'
   as opposed to Apple's very own example code
 */
+ (NSDictionary *)newiCloudStoreOptions;

+ (void)archiveUbiquityToken:(id)token;

+ (id)ubiquityTokenFromArchive;

+ (void)dropUbiquityToken;
@end
