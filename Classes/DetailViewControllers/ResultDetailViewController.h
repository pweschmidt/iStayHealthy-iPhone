//
//  ResultDetailViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 04/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResultValueCell.h"
#import "PressureCell.h"
@class SetDateCell, Results;

@interface ResultDetailViewController : UITableViewController <UIActionSheetDelegate, UIAlertViewDelegate,ResultValueCellDelegate, PressureCellDelegate>

@property (nonatomic, strong) NSDate *resultsDate;
@property (nonatomic, strong) Results *results;
@property (nonatomic, strong) SetDateCell *setDateCell;
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
@property (nonatomic, strong) UISwitch * undetectableSwitch;
- (IBAction) save:					(id) sender;
- (IBAction) cancel:				(id) sender;
- (void)changeResultsDate;
- (void)removeSQLEntry;
- (IBAction) showAlertView:			(id) sender;

- (id)initWithContext:(NSManagedObjectContext *)context;
- (id)initWithResults:(Results *)results context:(NSManagedObjectContext *)context;

- (NSNumber *)valueFromString:(NSString *)string;
- (void)indexDidChangeForSegment;
@end
