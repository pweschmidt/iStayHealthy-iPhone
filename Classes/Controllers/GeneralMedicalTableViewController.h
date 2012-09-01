//
//  GeneralMedicalTableViewController.h
//  iStayHealthy
//
//  Created by peterschmidt on 08/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iStayHealthyTableViewController.h"
#import "GeneralButtonCell.h"
#import <MessageUI/MessageUI.h>

@class iStayHealthyRecord, iStayHealthyTableViewController;
@interface GeneralMedicalTableViewController : iStayHealthyTableViewController
<UIActionSheetDelegate, GeneralButtonCellDelegate, MFMailComposeViewControllerDelegate>{
    int selectedContactRow;
}
@property int selectedContactRow;
- (void) showActionSheetForContact:(int)row;
- (void)startEmailMessageView:(NSString *)emailAddress;
- (void)loadClinicWebview:(NSString *)url withTitle:(NSString *)navTitle;
@end
