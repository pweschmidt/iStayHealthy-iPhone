//
//  iStayHealthyPasswordController.h
//  iStayHealthy
//
//  Created by peterschmidt on 06/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class iStayHealthyTabBarController;
@interface iStayHealthyPasswordController : UIViewController<UITextFieldDelegate, NSFetchedResultsControllerDelegate>{
	NSFetchedResultsController *fetchedResultsController_;
    iStayHealthyTabBarController *tabBarController;
    IBOutlet UITextField *passwordField;
    IBOutlet UILabel *label;
    IBOutlet UILabel *versionLabel;
    NSString *passwordString;
}
@property (nonatomic, retain) IBOutlet UITextField *passwordField;
@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, retain) IBOutlet UILabel *versionLabel;
@property (nonatomic, readonly) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) iStayHealthyTabBarController *tabBarController;
- (void)loadTabController;
- (IBAction)testLoad:(id)sender;
- (IBAction)textFieldDoneEditing:(id)sender;
- (void)dismissTabBarController;
@end
