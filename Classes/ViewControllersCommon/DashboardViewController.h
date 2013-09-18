//
//  DashboardViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 18/09/2013.
//
//

#import <UIKit/UIKit.h>

@interface DashboardViewController : UIViewController <UIScrollViewDelegate>
@property (nonatomic, weak) UIScrollView *chartScroller;
@property (nonatomic, weak) UIPageControl *pageController;
@property (nonatomic, weak) UIBarButtonItem * syncButton;
- (void)resync:(id)sender;
- (void)changePage:(id)sender;
@end
