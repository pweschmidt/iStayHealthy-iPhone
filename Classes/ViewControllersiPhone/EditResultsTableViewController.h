//
//  EditResultsTableViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 13/08/2013.
//
//

#import <UIKit/UIKit.h>
#import "BaseEditTableViewController.h"

@interface EditResultsTableViewController : BaseEditTableViewController
- (id)  initWithStyle:(UITableViewStyle)style
   importedAttributes:(NSDictionary *)importedAttributes
    hasNumericalInput:(BOOL)hasNumericalInput;
@end
