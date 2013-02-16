//
//  iStayHealthyPasswordController.h
//  iStayHealthy
//
//  Created by peterschmidt on 06/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class iStayHealthyTabBarController;
@interface iStayHealthyPasswordController : UIViewController<UITextFieldDelegate, NSFetchedResultsControllerDelegate>
- (void)loadTabController;
- (IBAction)testLoad:(id)sender;
- (IBAction)textFieldDoneEditing:(id)sender;
- (void)dismissTabBarController;
- (void)reloadData:(NSNotification*)note;
- (void)start;
@end
