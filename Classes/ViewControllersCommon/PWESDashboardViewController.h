//
//  PWESDashboardViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 05/07/2014.
//
//

#import "BaseViewController.h"
#import "ChartSelector.h"
#import <MessageUI/MessageUI.h>


@interface PWESDashboardViewController : BaseViewController <UIScrollViewDelegate, ChartSelector, MFMailComposeViewControllerDelegate>

@property (nonatomic, weak) UIScrollView *chartScroller;
@property (nonatomic, weak) UIPageControl *pageController;
@property (nonatomic, weak) UIBarButtonItem *syncButton;
- (void)changePage:(id)sender;
@end
