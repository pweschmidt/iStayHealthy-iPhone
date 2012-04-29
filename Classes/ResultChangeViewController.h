//
//  ResultChangeViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 14/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResultValueCell.h"

@class Results, iStayHealthyRecord, SetDateCell;
@interface ResultChangeViewController : UITableViewController <UIAlertViewDelegate, ResultValueCellDelegate, UIActionSheetDelegate>{
@private
	NSDate *resultsDate;
    Results                 *results;
    SetDateCell *changeDateCell;    
    iStayHealthyRecord *record;
    NSNumber *cd4;
    NSNumber *cd4Percent;
    NSNumber *vlHIV;
    NSNumber *vlHepC;
}
@property (nonatomic, retain) NSDate *resultsDate;
@property (nonatomic, retain) SetDateCell *changeDateCell;
@property (nonatomic, assign) Results *results;
@property (nonatomic, assign) iStayHealthyRecord *record;
@property (nonatomic, retain) NSNumber *cd4;
@property (nonatomic, retain) NSNumber *cd4Percent;
@property (nonatomic, retain) NSNumber *vlHIV;
@property (nonatomic, retain) NSNumber *vlHepC;
- (IBAction) save:					(id) sender;
- (IBAction) showAlertView:			(id) sender;
- (void)removeSQLEntry;
- (id)initWithResults:(Results *)_results withMasterRecord:(iStayHealthyRecord *)masterRecord;
- (NSNumber *)valueFromString:(NSString *)string;
- (void)changeResultsDate;
@end
