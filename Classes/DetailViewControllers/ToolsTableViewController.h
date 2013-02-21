//
//  ToolsTableViewController.h
//  iStayHealthy
//
//  Created by peterschmidt on 09/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class iStayHealthyRecord;

@interface ToolsTableViewController : UITableViewController<UITextFieldDelegate>
- (IBAction) done:				(id) sender;
- (IBAction) switchPasswordEnabling:(id)sender;
@end
