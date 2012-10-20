//
//  SQLDatabaseManager.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 20/10/2012.
//
//

#import <Foundation/Foundation.h>

@interface SQLDatabaseManager : NSObject
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator * persistentStoreCoordinator;
@property (nonatomic, strong, readonly) NSManagedObjectContext * mainObjectContext;
@property (nonatomic, strong, readonly) NSURL *mainStoreURL;
@property (nonatomic, strong, readonly) NSURL *backupStoreURL;
@property BOOL isUsingiCloud;
- (void)loadSQLitePersistentStore;
@end
