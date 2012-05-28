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
    Results                 *__unsafe_unretained results;
    SetDateCell *changeDateCell;    
    iStayHealthyRecord *__unsafe_unretained record;
    NSNumber *cd4;
    NSNumber *cd4Percent;
    NSNumber *vlHIV;
    NSNumber *vlHepC;
}
@property (nonatomic, strong) NSDate *resultsDate;
@property (nonatomic, strong) SetDateCell *changeDateCell;
@property (nonatomic, unsafe_unretained) Results *results;
@property (nonatomic, unsafe_unretained) iStayHealthyRecord *record;
@property (nonatomic, strong) NSNumber *cd4;
@property (nonatomic, strong) NSNumber *cd4Percent;
@property (nonatomic, strong) NSNumber *vlHIV;
@property (nonatomic, strong) NSNumber *vlHepC;
- (IBAction) save:					(id) sender;
- (IBAction) showAlertView:			(id) sender;
- (void)removeSQLEntry;
- (id)initWithResults:(Results *)_results withMasterRecord:(iStayHealthyRecord *)masterRecord;
- (NSNumber *)valueFromString:(NSString *)string;
- (void)changeResultsDate;
@end
