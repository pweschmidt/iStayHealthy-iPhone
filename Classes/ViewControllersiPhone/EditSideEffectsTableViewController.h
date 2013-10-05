//
//  EditSideEffectsTableViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/09/2013.
//
//

#import "BaseEditTableViewController.h"
#import "EffectsSelectionDataSource.h"

@interface EditSideEffectsTableViewController : BaseEditTableViewController
    <EffectsSelectionDataSource>
- (id)initWithStyle:(UITableViewStyle)style
        currentMeds:(NSArray *)currentMeds
      managedObject:(NSManagedObject *)managedObject;

@end
