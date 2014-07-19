//
//  EditSeinfeldCalendarTableViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 03/01/2014.
//
//

#import "BaseEditTableViewController.h"
@protocol PWESResultsDelegate;

@interface EditSeinfeldCalendarTableViewController : BaseEditTableViewController
@property (nonatomic, weak) id <PWESResultsDelegate> resultsDelegate;
- (id)initWithStyle:(UITableViewStyle)style calendars:(NSArray *)calendars;
@end
