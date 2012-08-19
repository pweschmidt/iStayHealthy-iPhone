//
//  SideEffectsDetailTableViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 19/08/2012.
//
//

#import <UIKit/UIKit.h>
@class iStayHealthyRecord, SideEffects, SetDateCell;

@interface SideEffectsDetailTableViewController : UITableViewController<UIActionSheetDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSDate *effectsDate;
@property (nonatomic, strong) iStayHealthyRecord *record;
@property (nonatomic, strong) SideEffects *sideEffects;
@property (nonatomic, strong) SetDateCell *setDateCell;
@property (nonatomic, strong) UISegmentedControl *seriousnessControl;

- (IBAction) seriousnessChanged:    (id) sender;
- (IBAction) save:					(id) sender;
- (IBAction) cancel:				(id) sender;
- (void)changeDate;
- (void)removeSQLEntry;
- (IBAction) showAlertView:			(id) sender;
- (id)initWithResults:(SideEffects *)effects
         masterRecord:(iStayHealthyRecord *)masterRecord;
- (id)initWithRecord:(iStayHealthyRecord *)masterrecord medication:(NSArray *)medArray;

@end
