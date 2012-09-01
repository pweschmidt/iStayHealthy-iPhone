//
//  ResultsSettingsTableViewController.h
//  iStayHealthy
//
//  Created by peterschmidt on 09/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class iStayHealthyRecord, SetDateCell;

@interface ResultsSettingsTableViewController : UITableViewController <UIActionSheetDelegate>
@property (nonatomic, strong) SetDateCell *setDateCell;
@property (nonatomic, strong) NSDate *dateOfBirth;
@property (nonatomic, strong) UISwitch *smokerSwitch;
@property (nonatomic, strong) UISwitch *diabeticSwitch;
@property (nonatomic, strong) iStayHealthyRecord *record;
- (id)initWithRecord:(iStayHealthyRecord *)masterRecord;
- (IBAction)switchSmoker:(id)sender;
- (IBAction)switchDiabetic:(id)sender;
- (void)changeDateOfBirth;   
@end
