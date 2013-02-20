//
//  HIVMedicationViewController.h
//  iStayHealthy
//
//  Created by peterschmidt on 29/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SQLDataTableController.h"
#import "StatusViewControllerLandscape.h"
#import "BasicViewController.h"

@interface HIVMedicationViewController : BasicViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) IBOutlet UITableView *tableView;
- (void)loadMedicationDetailViewController;
- (void)loadMedicationChangeDetailViewController:(NSIndexPath *)selectedIndexPath;
- (void)loadSideEffectsController;
- (void)loadMissedMedicationsController;
- (NSString *)getStringFromName:(NSString *)name;
@end
