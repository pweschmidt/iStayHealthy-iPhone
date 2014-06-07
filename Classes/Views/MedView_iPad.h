//
//  MedView_iPad.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 13/05/2014.
//
//

#import <UIKit/UIKit.h>
#import "Medication.h"
#import "MissedMedication.h"
#import "PreviousMedication.h"
#import "OtherMedication.h"
#import "SideEffects.h"
#import "Procedures.h"
#import "Contacts.h"

@interface MedView_iPad : UIView
+ (MedView_iPad *)viewForMedication:(Medication *)medication
                              frame:(CGRect)frame;

+ (MedView_iPad *)viewForMissedMedication:(MissedMedication *)medication
                                    frame:(CGRect)frame;

+ (MedView_iPad *)viewForPreviousMedication:(PreviousMedication *)medication
                                      frame:(CGRect)frame;

+ (MedView_iPad *)viewForOtherMedication:(OtherMedication *)medication
                                   frame:(CGRect)frame;

+ (MedView_iPad *)viewForSideEffects:(SideEffects *)medication
                               frame:(CGRect)frame;

+ (MedView_iPad *)viewForProcedures:(Procedures *)procedures
                              frame:(CGRect)frame;

+ (MedView_iPad *)viewForContacts:(Contacts *)contacts
                            frame:(CGRect)frame;

@end
