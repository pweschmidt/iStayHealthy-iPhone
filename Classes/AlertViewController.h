//
//  AlertViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 04/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iStayHealthyTableViewController.h"

@interface AlertViewController : iStayHealthyTableViewController{
	NSMutableArray *notificationsArray;
//    UIView *headerView;
}
@property (nonatomic, retain) NSMutableArray *notificationsArray;
//@property (nonatomic, retain) IBOutlet UIView *headerView;
- (void)loadMedAlertDetailViewController;
@end
