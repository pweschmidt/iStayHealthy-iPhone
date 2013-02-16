//
//  SettingsDetailViewController.h
//  iStayHealthy
//
//  Created by peterschmidt on 05/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface SettingsDetailViewController : UITableViewController <MFMailComposeViewControllerDelegate>
- (IBAction) done:	(id) sender;
- (void)startEmailMessageView;
- (void)startEmailResultsMessageView;
- (void)startDropBox;
- (void)startPasswordController;
- (void)gotoPOZ;
@end
