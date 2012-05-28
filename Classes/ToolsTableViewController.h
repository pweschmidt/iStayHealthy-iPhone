//
//  ToolsTableViewController.h
//  iStayHealthy
//
//  Created by peterschmidt on 09/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class iStayHealthyRecord;

@interface ToolsTableViewController : UITableViewController<UITextFieldDelegate, NSFetchedResultsControllerDelegate>{
	NSFetchedResultsController *fetchedResultsController_;
	iStayHealthyRecord *masterRecord;
    BOOL isPasswordEnabled;
    BOOL hasPassword;
    UISwitch *passwordSwitch;
    UITextField *passwordField;
    UITextField *passConfirmField;
    UIImageView *firstRightView;
    UIImageView *firstWrongView;
    UIImageView *secondRightView;
    UIImageView *secondWrongView;
    NSString *firstPassword;
    NSString *secondPassword;
    BOOL firstIsSet;
    BOOL secondIsSet;
    BOOL isConsistent;
}
@property (nonatomic, strong, readonly) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) iStayHealthyRecord *masterRecord;
@property BOOL isPasswordEnabled;
@property BOOL firstIsSet;
@property BOOL secondIsSet;
@property BOOL isConsistent;
@property (nonatomic, strong) NSString *firstPassword;
@property (nonatomic, strong) NSString *secondPassword;
@property (nonatomic, strong) UISwitch *passwordSwitch;
@property (nonatomic, strong) UITextField *passwordField;
@property (nonatomic, strong) UITextField *passConfirmField;
@property (nonatomic, strong) UIImageView *firstRightView;
@property (nonatomic, strong) UIImageView *firstWrongView;
@property (nonatomic, strong) UIImageView *secondRightView;
@property (nonatomic, strong) UIImageView *secondWrongView;
- (IBAction) done:				(id) sender;
- (IBAction) switchPasswordEnabling:(id)sender;

@end
