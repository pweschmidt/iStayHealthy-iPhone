//
//  PWESDashboardViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 05/07/2014.
//
//

#import "BaseViewController.h"
#import "ChartSelector.h"


@interface PWESDashboardViewController : BaseViewController <UIScrollViewDelegate, ChartSelector>
@property (nonatomic, weak) UIScrollView *chartScroller;
@property (nonatomic, weak) UIPageControl *pageController;
@property (nonatomic, weak) UIBarButtonItem *syncButton;
- (void)changePage:(id)sender;
@end
