//
//  Wellness.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 05/09/2012.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class iStayHealthyRecord;

@interface Wellness : NSManagedObject

@property (nonatomic, strong) NSNumber * sleepBarometer;
@property (nonatomic, strong) NSNumber * moodBarometer;
@property (nonatomic, strong) NSNumber * wellnessBarometer;
@property (nonatomic, strong) NSString * uID;
@property (nonatomic, strong) iStayHealthyRecord *record;

@end
