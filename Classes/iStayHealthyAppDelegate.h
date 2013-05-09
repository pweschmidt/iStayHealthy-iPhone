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

@class iStayHealthyTabBarController, iStayHealthyPasswordController, SQLDatabaseManager;

@interface iStayHealthyAppDelegate : NSObject <UIApplicationDelegate> 
@property BOOL iCloudIsAvailable;
@property (nonatomic, strong) NSURL *cloudURL;
@property (nonatomic, strong) NSString *relinkUserId;
@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) iStayHealthyPasswordController *passController;
@property (nonatomic, strong) iStayHealthyTabBarController *tabBarController;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong, readonly) SQLDatabaseManager *sqlHelper;

- (NSURL *)applicationDocumentsDirectory;
- (void)saveContext;
- (void)showReminder:(NSString *)text;
- (BOOL)handleFileImport:(NSURL *)url;
- (BOOL)handleParametersFromURL:(NSURL *)url;
extern NSString *MEDICATIONALERTKEY;
@end

