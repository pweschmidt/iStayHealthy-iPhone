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
	NSFetchedResultsController * fetchedResultsController_;
    iStayHealthyTabBarController *tabBarController;
    IBOutlet UITextField *passwordField;
    IBOutlet UILabel *label;
    IBOutlet UILabel *versionLabel;
    NSString *passwordString;
}
@property (nonatomic, strong) IBOutlet UITextField *passwordField;
@property (nonatomic, strong) IBOutlet UILabel *label;
@property (nonatomic, strong) IBOutlet UILabel *versionLabel;
@property (nonatomic, strong, readonly) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) iStayHealthyTabBarController *tabBarController;
- (void)loadTabController;
- (IBAction)testLoad:(id)sender;
- (IBAction)textFieldDoneEditing:(id)sender;
- (void)dismissTabBarController;
@end
