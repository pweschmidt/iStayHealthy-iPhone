//
//  HIVMedicationViewController.h
//  iStayHealthy
//
//  Created by peterschmidt on 29/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iStayHealthyTableViewController.h"

@interface HIVMedicationViewController : iStayHealthyTableViewController
- (void)loadMedicationDetailViewController;
- (void)loadMedicationChangeDetailViewController:(NSIndexPath *)selectedIndexPath;
- (void)loadSideEffectsController;
- (void)loadMissedMedicationsController;
- (NSString *)getStringFromName:(NSString *)name;
@end
