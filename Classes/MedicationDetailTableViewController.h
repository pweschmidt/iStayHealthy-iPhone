//
//  MedicationDetailTableViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 26/03/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class iStayHealthyRecord, SetDateCell;

@interface MedicationDetailTableViewController : UITableViewController <UIActionSheetDelegate> {

@private
	SetDateCell			*dateCell;
	NSArray             *combiTablets;
    NSArray             *proteaseInhibitors;
    NSArray             *nRTInihibtors;
    NSArray             *nNRTInhibitors;
    NSArray             *integraseInhibitors;
    NSArray             *entryInhibitors;
	NSMutableDictionary     *stateDictionary;
    BOOL                    isInitialLoad;
	NSDate *startDate;
	iStayHealthyRecord *record;
}
@property (nonatomic, retain) NSArray *combiTablets;
@property (nonatomic, retain) NSArray *proteaseInhibitors;
@property (nonatomic, retain) NSArray *nRTInihibtors;
@property (nonatomic, retain) NSArray *nNRTInhibitors;
@property (nonatomic, retain) NSArray *integraseInhibitors;
@property (nonatomic, retain) NSArray *entryInhibitors;
@property (nonatomic, retain) NSMutableDictionary *stateDictionary;
@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic, assign) iStayHealthyRecord *record;
@property (nonatomic, retain) SetDateCell *dateCell;
- (IBAction) save:					(id) sender;
- (IBAction) cancel:				(id) sender;
- (void)changeStartDate;
- (id)initWithRecord:(iStayHealthyRecord *)masterrecord;
@end
