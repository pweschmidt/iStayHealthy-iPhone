//
//  CoreDataUtils.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/08/2013.
//
//

#import <Foundation/Foundation.h>

@interface CoreDataUtils : NSObject
+ (NSDictionary *)localStoreOptions;

+ (NSDictionary *)iCloudStoreOptions;
@end
