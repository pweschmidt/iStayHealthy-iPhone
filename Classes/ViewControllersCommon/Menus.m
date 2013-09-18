//
//  Menus.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 23/08/2013.
//
//

#import "Menus.h"
#import "Constants.h"

@implementation Menus
+ (NSArray *)hamburgerMenus
{
    return  @[NSLocalizedString(@"Dashboard", nil),
              NSLocalizedString(@"Results", nil),
              NSLocalizedString(@"HIV Medications", nil),
              NSLocalizedString(@"Missed Meds", nil),
              NSLocalizedString(@"Side Effects", nil),
              NSLocalizedString(@"Medication Diary", nil),
              NSLocalizedString(@"Alerts", nil),
              NSLocalizedString(@"Appointments", nil),
              NSLocalizedString(@"Other Medication", nil),
              NSLocalizedString(@"Clinics", nil),
              NSLocalizedString(@"Procedures", nil),
              NSLocalizedString(@"Wellness", nil),
              NSLocalizedString(@"Login Password", nil),
              NSLocalizedString(@"Backups", nil),
              NSLocalizedString(@"Feedback", nil),
              NSLocalizedString(@"Info", nil)];
    
}
+ (NSArray *)addMenus
{
    return  @[NSLocalizedString(@"New Result", nil),
              NSLocalizedString(@"New HIV Med", nil),
              NSLocalizedString(@"New Other Med", nil),
              NSLocalizedString(@"New Missed Med", nil),
              NSLocalizedString(@"New Side Effects", nil),
              NSLocalizedString(@"New Alert", nil),
              NSLocalizedString(@"New Appointment", nil),
              NSLocalizedString(@"New Procedure", nil),
              NSLocalizedString(@"New Wellness", nil)];    
}

+ (NSString *)controllerNameForRowIndexPath:(NSIndexPath *)indexPath
                                ignoreFirst:(BOOL)ignoreFirst
{
    NSArray * menus = [Menus hamburgerMenus];
    if (indexPath.row > menus.count)
    {
        return nil;
    }
    NSUInteger index = (ignoreFirst) ? indexPath.row - 1 : indexPath.row;
    NSString *menuName = [menus objectAtIndex:index];
    if ([menuName isEqualToString:NSLocalizedString(@"Dashboard", nil)])
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
        
    }
    else if ([menuName isEqualToString:NSLocalizedString(@"Side Effects", nil)])
    {
        
    }
    else if ([menuName isEqualToString:NSLocalizedString(@"Medication Diary", nil)])
    {
        
    }
    else if ([menuName isEqualToString:NSLocalizedString(@"Alerts", nil)])
    {
        
    }
    else if ([menuName isEqualToString:NSLocalizedString(@"Appointments", nil)])
    {
        
    }
    else if ([menuName isEqualToString:NSLocalizedString(@"Other Medication", nil)])
    {
        
    }
    else if ([menuName isEqualToString:NSLocalizedString(@"Clinics", nil)])
    {
        
    }
    else if ([menuName isEqualToString:NSLocalizedString(@"Procedures", nil)])
    {
        
    }
    else if ([menuName isEqualToString:NSLocalizedString(@"Wellness", nil)])
    {
        
    }
    else if ([menuName isEqualToString:NSLocalizedString(@"Login Password", nil)])
    {
        
    }
    else if ([menuName isEqualToString:NSLocalizedString(@"Backups", nil)])
    {
        return kDropboxController;
    }
    else if ([menuName isEqualToString:NSLocalizedString(@"Feedback", nil)])
    {
        
    }
    else if ([menuName isEqualToString:NSLocalizedString(@"Info", nil)])
    {
        
    }
    return nil;
}

+ (NSString *)editControllerNameForRowIndexPath:(NSIndexPath *)indexPath
                                    ignoreFirst:(BOOL)ignoreFirst
{
    NSArray * menus = [Menus addMenus];
    if (indexPath.row > menus.count)
    {
        return nil;
    }
    NSUInteger index = (ignoreFirst) ? indexPath.row - 1 : indexPath.row;
    NSString *menuName = [menus objectAtIndex:index];
    return nil;
}


@end
