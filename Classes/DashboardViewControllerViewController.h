//
//  DashboardViewControllerViewController.h
//  iStayHealthy
//
//  Created by peterschmidt on 06/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#define NUMBEROFPAGES 3

@interface DashboardViewControllerViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
@property (nonatomic, weak) IBOutlet UITableView *detailedTableView;
@property (nonatomic, weak) IBOutlet UIView *headerView;
@property (nonatomic, weak) IBOutlet UIScrollView *chartScrollView;
@property (nonatomic, weak) IBOutlet UIPageControl *pageControl;
@property (nonatomic, weak) IBOutlet UIView *pageControlView;
- (IBAction)changePage:(id)sender;
@end
