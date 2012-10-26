//
//  SQLBackupStoreManager.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 26/10/2012.
//
//

#import <Foundation/Foundation.h>

@interface SQLBackupStoreManager : NSObject
- (void)transferDataToBackupStore;
- (void)transferDataFromBackupStore:(NSPersistentStoreCoordinator *)cloudCoordinator;
@end
