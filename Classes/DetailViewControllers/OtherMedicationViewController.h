//
//  OtherMedicationViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 10/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iStayHealthyTableViewController.h"
#import "MedicationCell.h"

@interface OtherMedicationViewController : iStayHealthyTableViewController {
	NSMutableArray *allMeds;
//    UIView *headerView;

}
@property (nonatomic, retain) NSMutableArray *allMeds;
//@property (nonatomic, retain) IBOutlet UIView *headerView;
- (void)loadOtherMedicationDetailViewController;
- (void)loadOtherMedicationChangeViewController:(int) row;
- (void)configureMedicationCell:(MedicationCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end
