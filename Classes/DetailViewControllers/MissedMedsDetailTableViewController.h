//
//  MissedMedsDetailTableViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 19/08/2012.
//
//

#import <UIKit/UIKit.h>
@class MissedMedication, SetDateCell;

@interface MissedMedsDetailTableViewController : UITableViewController<UIActionSheetDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) NSDate *missedDate;
@property (nonatomic, strong) MissedMedication *missedMeds;
@property (nonatomic, strong) SetDateCell *setDateCell;
- (IBAction) save:					(id) sender;
- (IBAction) cancel:				(id) sender;
- (void)changeDate;
- (void)removeSQLEntry;
- (IBAction) showAlertView:			(id) sender;
- (id)initWithMissedMedication:(MissedMedication*)missed;
- (id)initWithContext:(NSManagedObjectContext *)context medicationName:(NSString *)medicationName;
//- (id)initWithContext:(NSManagedObjectContext *)context medications:(NSArray *)medArray;

@end
