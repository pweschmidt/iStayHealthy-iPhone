//
//  SettingsTableViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 21/09/2013.
//
//

#import <UIKit/UIKit.h>
#import "PWESPopoverDelegate.h"

#import "BaseTableViewController.h"
@interface SettingsTableViewController : BaseTableViewController <UITextFieldDelegate, UIAlertViewDelegate>
@property (nonatomic, weak) id <PWESPopoverDelegate> popoverDelegate;
@end
