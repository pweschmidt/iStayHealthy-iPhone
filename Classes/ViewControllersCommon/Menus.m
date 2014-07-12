//
//  Menus.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 23/08/2013.
//
//

#import "Menus.h"
#import "Constants.h"
#import "Utilities.h"

@implementation Menus

+ (NSArray *)toolbarButtonItems
{
	static dispatch_once_t onceToken;
	static NSArray *items = nil;
	dispatch_once(&onceToken, ^{
	    items = @[
	            NSLocalizedString(@"Settings", nil),
	            NSLocalizedString(@"Backups", nil),
	            NSLocalizedString(@"Feedback", nil),
	            NSLocalizedString(@"Email Data", nil),
	            NSLocalizedString(@"Info", nil)
	        ];
	});
	return items;
}

+ (NSArray *)controllerMenu
{
	static dispatch_once_t onceToken;
	static NSArray *menus = nil;
	if ([Utilities isIPad])
	{
		dispatch_once(&onceToken, ^{
		    menus = @[kDashboardController,
		              kResultsController,
		              kHIVMedsController,
		              kMissedController,
		              kSideEffectsController,
		              kMedicationDiaryController,
		              kAlertsController,
		              kOtherMedsController,
		              kClinicsController,
		              kProceduresController,
		              kWellnessController];
		});
	}
	else
	{
		dispatch_once(&onceToken, ^{
		    menus = @[kDashboardController,
		              kResultsController,
		              kHIVMedsController,
		              kMissedController,
		              kSideEffectsController,
		              kMedicationDiaryController,
		              kAlertsController,
		              kOtherMedsController,
		              kClinicsController,
		              kProceduresController,
		              kSettingsController,
		              kDropboxController,
		              kEmailController,
		              kInfoController];
		});
	}
	return menus;
}

+ (NSArray *)hamburgerMenus
{
	static dispatch_once_t onceToken;
	static NSArray *menus = nil;
	dispatch_once(&onceToken, ^{
	    menus = @[NSLocalizedString(@"Charts", nil),
	              NSLocalizedString(@"Results", nil),
	              NSLocalizedString(@"HIV Medications", nil),
	              NSLocalizedString(@"Missed Meds", nil),
	              NSLocalizedString(@"Side Effects", nil),
	              NSLocalizedString(@"Medication Diary", nil),
	              NSLocalizedString(@"Alerts", nil),
	              NSLocalizedString(@"Other Medication", nil),
	              NSLocalizedString(@"Clinics", nil),
	              NSLocalizedString(@"Procedures", nil)];
	});
	return menus;
}

+ (NSArray *)addMenus
{
	if ([Utilities isIPad])
	{
		return @[NSLocalizedString(@"New Result", nil),
		         NSLocalizedString(@"New HIV Med", nil),
		         NSLocalizedString(@"New Other Med", nil),
		         NSLocalizedString(@"New Missed Med", nil),
		         NSLocalizedString(@"New Side Effects", nil),
		         NSLocalizedString(@"New Alert", nil),
		         NSLocalizedString(@"New Procedure", nil),
		         NSLocalizedString(@"New Wellness", nil)];
	}
	else
	{
		return @[NSLocalizedString(@"New Result", nil),
		         NSLocalizedString(@"New HIV Med", nil),
		         NSLocalizedString(@"New Other Med", nil),
		         NSLocalizedString(@"New Missed Med", nil),
		         NSLocalizedString(@"New Side Effects", nil),
		         NSLocalizedString(@"New Alert", nil),
		         NSLocalizedString(@"New Procedure", nil)];
	}
}

+ (NSString *)controllerNameForRowIndexPath:(NSIndexPath *)indexPath
                                ignoreFirst:(BOOL)ignoreFirst
{
	NSArray *menus = [Menus hamburgerMenus];
	if (indexPath.row > menus.count)
	{
		return nil;
	}
	NSUInteger index = (ignoreFirst) ? indexPath.row - 1 : indexPath.row;
	NSString *menuName = [menus objectAtIndex:index];
	if ([menuName isEqualToString:NSLocalizedString(@"Charts", nil)])
	{
		return kDashboardController;
	}
	else if ([menuName isEqualToString:NSLocalizedString(@"Results", nil)])
	{
		return kResultsController;
	}
	else if ([menuName isEqualToString:NSLocalizedString(@"HIV Medications", nil)])
	{
		return kHIVMedsController;
	}
	else if ([menuName isEqualToString:NSLocalizedString(@"Missed Meds", nil)])
	{
		return kMissedController;
	}
	else if ([menuName isEqualToString:NSLocalizedString(@"Side Effects", nil)])
	{
		return kSideEffectsController;
	}
	else if ([menuName isEqualToString:NSLocalizedString(@"Medication Diary", nil)])
	{
		return kMedicationDiaryController;
	}
	else if ([menuName isEqualToString:NSLocalizedString(@"Alerts", nil)])
	{
		return kAlertsController;
	}
	else if ([menuName isEqualToString:NSLocalizedString(@"Other Medication", nil)])
	{
		return kOtherMedsController;
	}
	else if ([menuName isEqualToString:NSLocalizedString(@"Clinics", nil)])
	{
		return kClinicsController;
	}
	else if ([menuName isEqualToString:NSLocalizedString(@"Procedures", nil)])
	{
		return kProceduresController;
	}
	else if ([menuName isEqualToString:NSLocalizedString(@"Wellness", nil)])
	{
		return kWellnessController;
	}
	else if ([menuName isEqualToString:NSLocalizedString(@"Settings", nil)])
	{
		return kSettingsController;
	}
	else if ([menuName isEqualToString:NSLocalizedString(@"Backups", nil)])
	{
		return kDropboxController;
	}
	else if ([menuName isEqualToString:NSLocalizedString(@"Info", nil)])
	{
		return kInfoController;
	}
//	else if ([menuName isEqualToString:NSLocalizedString(@"Feedback", nil)])
//	{
//		return kFeedbackController;
//	}
	else if ([menuName isEqualToString:NSLocalizedString(@"Email Data", nil)])
	{
		return kEmailController;
	}
	return nil;
}

+ (NSString *)editControllerNameForRowIndexPath:(NSIndexPath *)indexPath
                                    ignoreFirst:(BOOL)ignoreFirst
{
	NSArray *menus = [Menus addMenus];
	if (indexPath.row > menus.count)
	{
		return nil;
	}
	NSUInteger index = (ignoreFirst) ? indexPath.row - 1 : indexPath.row;
	NSString *menuName = [menus objectAtIndex:index];
	return menuName;
}

+ (NSDictionary *)menuImages
{
	static dispatch_once_t onceToken;
	static NSDictionary *colourDictionary = nil;
	dispatch_once(&onceToken, ^{
	    colourDictionary = @{
	        kDashboardController : [UIImage imageNamed:@"charts-icon.png"],
	        kResultsController : [UIImage imageNamed:@"results-icon.png"],
	        kHIVMedsController : [UIImage imageNamed:@"combi-icon.png"],
	        kMissedController : [UIImage imageNamed:@"missed-icon.png"],
	        kAlertsController : [UIImage imageNamed:@"alarm-icon.png"],
	        kClinicsController : [UIImage imageNamed:@"hospital-icon.png"],
	        kSideEffectsController : [UIImage imageNamed:@"sideeffects-icon.png"],
	        kDropboxController : [UIImage imageNamed:@"save.png"],
	        kOtherMedsController : [UIImage imageNamed:@"cross-icon.png"],
	        kInfoController : [UIImage imageNamed:@"info.png"],
//	        kFeedbackController : [UIImage imageNamed:@"feedback.png"],
	        kEmailController : [UIImage imageNamed:@"mail.png"],
	        kProceduresController : [UIImage imageNamed:@"procedure-icon.png"],
	        kSettingsController : [UIImage imageNamed:@"lock.png"],
	        kMedicationDiaryController : [UIImage imageNamed:@"diary-icon.png"]
		};
	});
	return colourDictionary;
}

+ (NSDictionary *)soundFiles
{
	static dispatch_once_t onceToken;
	static NSDictionary *files = nil;
	dispatch_once(&onceToken, ^{
	    files = @{ NSLocalizedString(@"Default", nil) : UILocalNotificationDefaultSoundName,
	               @"Chimes" : @"chimes.caf",
	               @"Polyphonic 1" : @"polyphonic1.caf",
	               @"Polyphonic 2" : @"polyphonic2.caf",
	               @"Ringtone 1" : @"ringtone1.caf",
	               @"Ringtone 2" : @"ringtone2.caf",
	               @"Xylophone" : @"xylophone.caf" };
	});
	return files;
}

+ (UIImageView *)buttonImageviewForTitle:(NSString *)title
{
	UIImage *image = nil;
	if ([title isEqualToString:NSLocalizedString(@"Settings", nil)])
	{
		image = [UIImage imageNamed:@"lock.png"];
	}
	else if ([title isEqualToString:NSLocalizedString(@"Backups", nil)])
	{
		image = [UIImage imageNamed:@"backup.png"];
	}
	else if ([title isEqualToString:NSLocalizedString(@"Feedback", nil)])
	{
		image = [UIImage imageNamed:@"feedback.png"];
	}
	else if ([title isEqualToString:NSLocalizedString(@"Email Data", nil)])
	{
		image = [UIImage imageNamed:@"mail.png"];
	}
	else if ([title isEqualToString:NSLocalizedString(@"Info", nil)])
	{
		image = [UIImage imageNamed:@"info.png"];
	}
	else
	{
		return nil;
	}
	UIImageView *menuView = [[UIImageView alloc] initWithImage:image];
	menuView.backgroundColor = [UIColor clearColor];
	menuView.frame = CGRectMake(0, 0, 20, 20);

	return menuView;
}

@end
