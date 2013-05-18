//
//  iStayHealthyPasswordController.h
//  iStayHealthy
//
//  Created by peterschmidt on 06/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@class iStayHealthyTabBarController;
@interface iStayHealthyPasswordController : UIViewController<UITextFieldDelegate, MFMailComposeViewControllerDelegate>
@property (nonatomic, strong) IBOutlet UIButton * forgotButton;
- (void)loadTabController;
- (IBAction)testLoad:(id)sender;
- (IBAction)textFieldDoneEditing:(id)sender;
- (void)dismissTabBarController;
- (void)reloadData:(NSNotification *)note;
- (void)start;
- (IBAction)sendMail:(id)sender;
@end
