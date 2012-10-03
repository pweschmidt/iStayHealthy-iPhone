//
//  iStayHealthyAppDelegate.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 04/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#define BACKGROUNDCOLOUR [UIColor colorWithRed:253.0/255.0 green:255.0/255.0 blue:240.0/255.0 alpha:1.0]

@class iStayHealthyTabBarController, iStayHealthyPasswordController, SQLiteHelper;

@interface iStayHealthyAppDelegate : NSObject <UIApplicationDelegate, NSFetchedResultsControllerDelegate> 
@property BOOL iCloudIsAvailable;
@property (nonatomic, strong) NSURL *cloudURL;
@property (nonatomic, strong) NSString *relinkUserId;
@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) iStayHealthyPasswordController *passController;
@property (nonatomic, strong) iStayHealthyTabBarController *tabBarController;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong, readonly) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong, readonly) SQLiteHelper *sqlHelper;

- (NSURL *)applicationDocumentsDirectory;
- (void)saveContext;
- (void)showReminder:(NSString *)text;
//- (void)setUpMasterRecord;
//- (void)mergeiCloudChanges:(NSNotification*)note
//                forContext:(NSManagedObjectContext*)moc;
- (BOOL)handleFileImport:(NSURL *)url;
extern NSString *MEDICATIONALERTKEY;
@end

