//
//  ResultsListViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 04/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iStayHealthyTableViewController.h"
#import "ResultCell.h"
@interface ResultsListViewController : iStayHealthyTableViewController {
	NSMutableArray *allResults;
//    UIView *headerView;
}
@property (nonatomic, retain) NSMutableArray *allResults;
//@property (nonatomic, retain) IBOutlet UIView *headerView;
- (void)loadResultDetailViewController;
- (void)loadResultChangeViewController:(int)row;
- (void)configureResultCell:(ResultCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end
