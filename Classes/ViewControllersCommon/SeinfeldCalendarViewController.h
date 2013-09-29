//
//  SeinfeldCalendarViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 21/09/2013.
//
//

#import "BaseViewController.h"

@interface SeinfeldCalendarViewController : BaseViewController <UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *calendarScrollView;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;

@end
