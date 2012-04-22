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

@class iStayHealthyTabBarController, iStayHealthyPasswordController;

@interface iStayHealthyAppDelegate : NSObject <UIApplicationDelegate, NSFetchedResultsControllerDelegate> {
    
    UIWindow *window;
    iStayHealthyTabBarController *tabBarController;
    iStayHealthyPasswordController *passController;
	NSString *relinkUserId;
    BOOL     iCloudIsAvailable;
    NSURL   *cloudURL;
@private
	NSFetchedResultsController *fetchedResultsController_;
    NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;
}
@property (assign) NSURL *cloudURL;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) iStayHealthyPasswordController *passController;
@property (nonatomic, retain) iStayHealthyTabBarController *tabBarController;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, readonly) NSFetchedResultsController *fetchedResultsController;

- (NSURL *)applicationDocumentsDirectory;
- (void)saveContext;
- (void)showReminder:(NSString *)text;
- (void)setUpMasterRecord;
- (void)mergeiCloudChanges:(NSNotification*)note 
                forContext:(NSManagedObjectContext*)moc;
- (void)checkForiCloud;
- (BOOL)handleFileImport:(NSURL *)url;
extern NSString *MEDICATIONALERTKEY;
@end

