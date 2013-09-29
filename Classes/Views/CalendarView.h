//
//  CalendarView.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 29/09/2013.
//
//

#import <UIKit/UIKit.h>

@interface CalendarView : UIView <UIAlertViewDelegate>
@property (nonatomic, strong) NSDictionary *diary;
+ (CalendarView *)calenderViewForDate:(NSDate *)date frame:(CGRect)frame;
- (IBAction)checkIfMissed:(id)sender;
@end
