//
//  ResultDetailViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 04/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResultValueCell.h"
@class iStayHealthyRecord, SetDateCell, Results;

@interface ResultDetailViewController : UITableViewController <UIActionSheetDelegate, ResultValueCellDelegate>{
@private
	NSDate *resultsDate;
    SetDateCell *setDateCell;
	iStayHealthyRecord *__unsafe_unretained record;
    NSNumber *cd4;
    NSNumber *cd4Percent;
    NSNumber *vlHIV;
    NSNumber *vlHepC;
}
@property (nonatomic, strong) NSDate *resultsDate;
@property (nonatomic, unsafe_unretained) iStayHealthyRecord *record;
@property (nonatomic, strong) SetDateCell *setDateCell;
@property (nonatomic, strong) NSNumber *cd4;
@property (nonatomic, strong) NSNumber *cd4Percent;
@property (nonatomic, strong) NSNumber *vlHIV;
@property (nonatomic, strong) NSNumber *vlHepC;
- (IBAction) save:					(id) sender;
- (IBAction) cancel:				(id) sender;
- (void)changeResultsDate;
- (id)initWithRecord:(iStayHealthyRecord *)masterrecord;
- (NSNumber *)valueFromString:(NSString *)string;
@end
