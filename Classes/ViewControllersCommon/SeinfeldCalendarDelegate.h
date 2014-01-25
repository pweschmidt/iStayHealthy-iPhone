//
//  SeinfeldCalendarDelegate.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 25/01/2014.
//
//

#import <Foundation/Foundation.h>

@protocol SeinfeldCalendarDelegate <NSObject>
- (void)popToMissedMedicationControllerHasMissed:(BOOL)hasMissed;
- (void)courseHasEndedHasMissedMedsOnLastDay:(BOOL)hasMissedMedsOnLastDay;
@end
