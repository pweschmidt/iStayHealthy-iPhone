//
//  MedicationViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 04/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iStayHealthyTableViewController.h"
@class MedicationCell;

@interface MedicationViewController : iStayHealthyTableViewController {
	NSMutableArray *allMeds;
    NSMutableArray *allMissedMedDates;
//    UIView *headerView;
}
@property (nonatomic, retain) NSMutableArray *allMeds;
@property (nonatomic, retain) NSMutableArray *allMissedMedDates;
//@property (nonatomic, retain) IBOutlet UIView *headerView;
- (void)loadMedicationDetailViewController;
- (void)configureMedicationCell:(MedicationCell *)cell atRow:(int)row;
- (void)configureMissedMedicationCell:(MedicationCell *)cell atRow:(int)row;
- (void)loadMedicationChangeDetailViewController:(NSIndexPath *)selectedIndexPath;
@end
