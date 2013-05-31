//
//  SQLDatabaseManager.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 20/10/2012.
//
//

#import <Foundation/Foundation.h>

@interface SQLDatabaseManager : NSObject <UIAlertViewDelegate>
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator * persistentStoreCoordinator;
@property (nonatomic, strong, readonly) NSManagedObjectContext * mainObjectContext;
@property (nonatomic, strong, readonly) NSURL *mainStoreURL;
@property (nonatomic, strong, readonly) NSURL *backupStoreURL;
- (void)loadSQLitePersistentStore;
- (void)importDataFromURL:(NSURL *)url;
@end
