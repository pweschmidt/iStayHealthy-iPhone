//
//  ProcedureTableViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 31/08/2012.
//
//

#import <UIKit/UIKit.h>
#import "iStayHealthyTableViewController.h"

@interface ProcedureTableViewController : iStayHealthyTableViewController
- (void)loadDetailProcedureViewController;
- (void)loadEditProcedureViewControllerForId:(NSUInteger)rowId;
- (IBAction)done:(id)sender;
@end
