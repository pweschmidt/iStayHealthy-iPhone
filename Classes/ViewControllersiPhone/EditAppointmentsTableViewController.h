//
//  EditAppointmentsTableViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/09/2013.
//
//

#import "BaseEndDateTableViewController.h"

@interface EditAppointmentsTableViewController : BaseEndDateTableViewController
- (id)initWithStyle:(UITableViewStyle)style
     currentClinics:(NSArray *)currentClinics
      managedObject:(NSManagedObject *)managedObject;

@end
