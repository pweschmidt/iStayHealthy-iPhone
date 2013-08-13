//
//  EditResultsTableViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 13/08/2013.
//
//

#import <UIKit/UIKit.h>

@class Results;

@interface EditResultsTableViewController : UITableViewController <UITextFieldDelegate>
- (id)initWithStyle:(UITableViewStyle)style results:(Results *)results;
@end
