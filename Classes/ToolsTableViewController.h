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
@property (nonatomic, readonly) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) iStayHealthyRecord *masterRecord;
@property BOOL isPasswordEnabled;
@property BOOL firstIsSet;
@property BOOL secondIsSet;
@property BOOL isConsistent;
@property (nonatomic, retain) NSString *firstPassword;
@property (nonatomic, retain) NSString *secondPassword;
@property (nonatomic, retain) UISwitch *passwordSwitch;
@property (nonatomic, retain) UITextField *passwordField;
@property (nonatomic, retain) UITextField *passConfirmField;
@property (nonatomic, retain) UIImageView *firstRightView;
@property (nonatomic, retain) UIImageView *firstWrongView;
@property (nonatomic, retain) UIImageView *secondRightView;
@property (nonatomic, retain) UIImageView *secondWrongView;
- (IBAction) done:				(id) sender;
- (IBAction) switchPasswordEnabling:(id)sender;

@end
