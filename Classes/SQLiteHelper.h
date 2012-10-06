//
//  SQLiteHelper.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 29/09/2012.
//
//

#import <Foundation/Foundation.h>

extern NSString * const kSQLiteiCloudStore;
extern NSString * const kSQLiteNoiCloudStore;

@interface SQLiteHelper : NSObject
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator * persistentStoreCoordinator;
@property (nonatomic, strong, readonly) NSManagedObjectContext * mainObjectContext;
@property (nonatomic, strong, readonly) NSURL * cloudURL;
- (void)loadSQLitePersistentStore;
@end
