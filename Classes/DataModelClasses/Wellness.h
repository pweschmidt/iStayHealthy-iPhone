//
//  Wellness.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 03/01/2014.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class iStayHealthyRecord;

@interface Wellness : NSManagedObject

@property (nonatomic, retain) NSNumber * moodBarometer;
@property (nonatomic, retain) NSNumber * wellnessBarometer;
@property (nonatomic, retain) NSString * uID;
@property (nonatomic, retain) NSNumber * sleepBarometer;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) iStayHealthyRecord *record;

@end
