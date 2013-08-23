//
//  Menus.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 23/08/2013.
//
//

#import "Menus.h"

@implementation Menus
+ (NSArray *)hamburgerMenus
{
    return  @[NSLocalizedString(@"Dashboard", nil),
              NSLocalizedString(@"Results", nil),
              NSLocalizedString(@"HIV Medication", nil),
              NSLocalizedString(@"Missed Meds", nil),
              NSLocalizedString(@"Side Effects", nil),
              NSLocalizedString(@"Previous Meds", nil),
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
@end
