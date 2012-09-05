//
//  MissedMedication.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 05/09/2012.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class iStayHealthyRecord;

@interface MissedMedication : NSManagedObject

@property (nonatomic, strong) NSString * UID;
@property (nonatomic, strong) NSString * Name;
@property (nonatomic, strong) NSDate * MissedDate;
@property (nonatomic, strong) NSString * Drug;
@property (nonatomic, strong) NSString * missedReason;
@property (nonatomic, strong) iStayHealthyRecord *record;

@end
