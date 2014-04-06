//
//  EditChartsTableViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 22/12/2013.
//
//

#import <UIKit/UIKit.h>
#import "ChartSelector.h"
#import "PWESPopoverDelegate.h"
@interface EditChartsTableViewController : UITableViewController <UIAlertViewDelegate>
@property (nonatomic, weak) id <ChartSelector> chartSelector;
@property (nonatomic, weak) id <PWESPopoverDelegate> customPopOverDelegate;
- (id)initWithSelectedItems:(NSArray *)items;
@end
