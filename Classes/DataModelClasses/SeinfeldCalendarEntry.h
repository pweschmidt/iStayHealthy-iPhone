//
//  SeinfeldCalendarEntry.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 03/01/2014.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SeinfeldCalendar;

@interface SeinfeldCalendarEntry : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * hasTakenMeds;
@property (nonatomic, retain) NSString * uID;
@property (nonatomic, retain) SeinfeldCalendar *calendar;

@end
