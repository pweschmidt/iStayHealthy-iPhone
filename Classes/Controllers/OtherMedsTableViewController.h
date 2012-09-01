//
//  OtherMedsTableViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 31/08/2012.
//
//

#import <UIKit/UIKit.h>
#import "iStayHealthyTableViewController.h"

@interface OtherMedsTableViewController : iStayHealthyTableViewController
- (void)loadDetailOtherMedsController;
- (void)loadEditMedsControllerForId:(NSUInteger)rowId;
- (IBAction)done:(id)sender;
@end
