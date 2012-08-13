//
//  ResultChangeViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 14/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResultValueCell.h"
#import "MoreResultsViewController.h"
#import "PressureCell.h"

@class Results, iStayHealthyRecord, SetDateCell;
@interface ResultChangeViewController : UITableViewController <UIAlertViewDelegate, ResultValueCellDelegate, UIActionSheetDelegate, PressureCellDelegate>{
}
@property (nonatomic, strong) NSDate *resultsDate;
@property (nonatomic, strong) SetDateCell *changeDateCell;
@property (nonatomic, strong) Results *results;
@property (nonatomic, strong) iStayHealthyRecord *record;
@property (nonatomic, strong) NSNumber *cd4;
@property (nonatomic, strong) NSNumber *cd4Percent;
@property (nonatomic, strong) NSNumber *vlHIV;
@property (nonatomic, strong) NSNumber *vlHepC;
@property (nonatomic, strong) NSNumber *glucose;
@property (nonatomic, strong) NSNumber *hdl;
@property (nonatomic, strong) NSNumber *ldl;
@property (nonatomic, strong) NSNumber *cholesterol;
@property (nonatomic, strong) NSNumber *weight;
@property (nonatomic, strong) NSNumber *systole;
@property (nonatomic, strong) NSNumber *diastole;
@property (nonatomic, strong) NSNumber *hemoglobulin;
@property (nonatomic, strong) NSNumber *whiteCells;
@property (nonatomic, strong) NSNumber *redCells;
@property (nonatomic, strong) NSNumber *platelets;
@property (nonatomic, strong) UISegmentedControl *resultsSegmentControl;

- (IBAction) save:					(id) sender;
- (IBAction) showAlertView:			(id) sender;
- (void)removeSQLEntry;
- (id)initWithResults:(Results *)storedResults withMasterRecord:(iStayHealthyRecord *)masterRecord;
- (NSNumber *)valueFromString:(NSString *)string;
- (void)changeResultsDate;
- (void)indexDidChangeForSegment;
@end
