//
//  PreviousMedication.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 05/09/2012.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class iStayHealthyRecord;

@interface PreviousMedication : NSManagedObject

@property (nonatomic, strong) NSDate * startDate;
@property (nonatomic, strong) NSDate * endDate;
@property (nonatomic, strong) NSNumber * isART;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * drug;
@property (nonatomic, strong) NSString * reasonEnded;
@property (nonatomic, strong) NSString * uID;
@property (nonatomic, strong) iStayHealthyRecord *record;

@end
