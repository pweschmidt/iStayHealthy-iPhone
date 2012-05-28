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
    NSURL   *__unsafe_unretained cloudURL;
@private
	NSFetchedResultsController *__unsafe_unretained fetchedResultsController_;
    NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;
}
@property (unsafe_unretained) NSURL *cloudURL;
@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) iStayHealthyPasswordController *passController;
@property (nonatomic, strong) iStayHealthyTabBarController *tabBarController;
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (unsafe_unretained, nonatomic, readonly) NSFetchedResultsController *fetchedResultsController;

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

