//
//  EditChartsTableViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 22/12/2013.
//
//

#import <UIKit/UIKit.h>
#import "ChartSelector.h"
@interface EditChartsTableViewController : UITableViewController
@property (nonatomic, weak) id<ChartSelector>chartSelector;
- (id)initWithSelectedItems:(NSArray *)items;
@end
