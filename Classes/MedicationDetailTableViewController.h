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
	iStayHealthyRecord *__unsafe_unretained record;
}
@property (nonatomic, strong) NSArray *combiTablets;
@property (nonatomic, strong) NSArray *proteaseInhibitors;
@property (nonatomic, strong) NSArray *nRTInihibtors;
@property (nonatomic, strong) NSArray *nNRTInhibitors;
@property (nonatomic, strong) NSArray *integraseInhibitors;
@property (nonatomic, strong) NSArray *entryInhibitors;
@property (nonatomic, strong) NSMutableDictionary *stateDictionary;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, unsafe_unretained) iStayHealthyRecord *record;
@property (nonatomic, strong) SetDateCell *dateCell;
- (IBAction) save:					(id) sender;
- (IBAction) cancel:				(id) sender;
- (void)changeStartDate;
- (id)initWithRecord:(iStayHealthyRecord *)masterrecord;
@end
