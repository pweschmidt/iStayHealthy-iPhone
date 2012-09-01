//
//  DashboardViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 29/08/2012.
//
//

#import <UIKit/UIKit.h>

@interface DashboardViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
@property (nonatomic, strong)  IBOutlet UITableView *detailedTableView;
@property (nonatomic, strong)  UIScrollView *scrollView;
@property (nonatomic, strong)  IBOutlet UIView *pageControllerView;
@property (nonatomic, strong)  IBOutlet UIPageControl *pageControl;
- (IBAction)changePage:(id)sender;

@end
