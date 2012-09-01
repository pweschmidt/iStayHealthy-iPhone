//
//  ClinicsTableViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 31/08/2012.
//
//

#import <UIKit/UIKit.h>
#import "iStayHealthyTableViewController.h"

@interface ClinicsTableViewController : iStayHealthyTableViewController
- (void)loadClinicDetailViewController;
- (void)loadClinicEditViewControllerForContactId:(NSUInteger) rowId;
- (IBAction)done:(id)sender;
@end
