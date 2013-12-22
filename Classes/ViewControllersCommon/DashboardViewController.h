//
//  DashboardViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 18/09/2013.
//
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "ChartSelector.h"

@interface DashboardViewController : BaseViewController <UIScrollViewDelegate, ChartSelector>
@property (nonatomic, weak) UIScrollView *chartScroller;
@property (nonatomic, weak) UIPageControl *pageController;
@property (nonatomic, weak) UIBarButtonItem * syncButton;
- (void)changePage:(id)sender;
@end
