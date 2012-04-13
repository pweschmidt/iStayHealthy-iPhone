//
//  ResultDetailViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 04/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResultValueCell.h"
@class iStayHealthyRecord, SetDateCell;

@interface ResultDetailViewController : UITableViewController <UIActionSheetDelegate, ResultValueCellDelegate>{
@private
	NSDate *resultsDate;
    SetDateCell *setDateCell;
	iStayHealthyRecord *record;
    NSNumber *cd4;
    NSNumber *cd4Percent;
    NSNumber *vlHIV;
    NSNumber *vlHepC;
}
@property (nonatomic, retain) NSDate *resultsDate;
@property (nonatomic, assign) iStayHealthyRecord *record;
@property (nonatomic, retain) SetDateCell *setDateCell;
@property (nonatomic, retain) NSNumber *cd4;
@property (nonatomic, retain) NSNumber *cd4Percent;
@property (nonatomic, retain) NSNumber *vlHIV;
@property (nonatomic, retain) NSNumber *vlHepC;
- (IBAction) save:					(id) sender;
- (IBAction) cancel:				(id) sender;
- (void)changeResultsDate;
- (id)initWithRecord:(iStayHealthyRecord *)masterrecord;
- (NSNumber *)valueFromString:(NSString *)string;
@end
