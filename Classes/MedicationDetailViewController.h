//
//  MedicationDetailViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 08/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class iStayHealthyRecord, DateLabelCell, EditableTableCell;

@interface MedicationDetailViewController : UITableViewController <UIActionSheetDelegate,UIPickerViewDelegate, UIPickerViewDataSource>{
	DateLabelCell			*dateLabelCell;
	EditableTableCell		*otherCombiDrugCell;
	UIPickerView			*medsPicker;
	NSMutableArray			*availableMeds;
	NSMutableArray			*combiTablets;
    NSMutableArray          *proteaseInhibitors;
    NSMutableArray          *nRTInihibtors;
    NSMutableArray          *nNRTInhibitors;
    NSMutableArray          *integraseInhibitors;
    NSMutableArray          *entryInhibitors;
@private
	NSDate *startDate;
	iStayHealthyRecord *record;
	
}
@property (nonatomic, retain) NSMutableArray *availableMeds;
@property (nonatomic, retain) NSMutableArray *combiTablets;
@property (nonatomic, retain) NSMutableArray *proteaseInhibitors;
@property (nonatomic, retain) NSMutableArray *nRTInihibtors;
@property (nonatomic, retain) NSMutableArray *nNRTInhibitors;
@property (nonatomic, retain) NSMutableArray *integraseInhibitors;
@property (nonatomic, retain) NSMutableArray *entryInhibitors;

@property (nonatomic, retain) IBOutlet DateLabelCell *dateLabelCell;
@property (nonatomic, retain) IBOutlet EditableTableCell *otherCombiDrugCell;
@property (nonatomic, retain) IBOutlet UIPickerView *medsPicker;
@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic, retain) iStayHealthyRecord *record;
- (IBAction) save:					(id) sender;
- (IBAction) cancel:				(id) sender;
- (void)changeStartDate;

@end
