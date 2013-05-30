//
//  SideEffectsDetailTableViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 19/08/2012.
//
//

#import <UIKit/UIKit.h>
#import "ClinicAddressCell.h"
@class SideEffects, SetDateCell;

@protocol EffectsSelector <NSObject>
- (void)selectedEffectFromList:(NSString *)effect;
@end


@interface SideEffectsDetailTableViewController : UITableViewController<UIActionSheetDelegate, UIAlertViewDelegate, EffectsSelector, ClinicAddressCellDelegate>

@property (nonatomic, strong) NSDate *effectsDate;
@property (nonatomic, strong) SideEffects *sideEffects;
@property (nonatomic, strong) SetDateCell *setDateCell;
@property (nonatomic, strong) ClinicAddressCell *selectedEffectCell;
@property (nonatomic, strong) UISegmentedControl *seriousnessControl;

- (IBAction) seriousnessChanged:    (id) sender;
- (IBAction) save:					(id) sender;
- (IBAction) cancel:				(id) sender;
- (void)changeDate;
- (void)removeSQLEntry;
- (IBAction) showAlertView:			(id) sender;
- (id)initWithSideEffects:(SideEffects *)effects;
- (id)initWithContext:(NSManagedObjectContext  *)context medications:(NSArray *)medications;
@end
