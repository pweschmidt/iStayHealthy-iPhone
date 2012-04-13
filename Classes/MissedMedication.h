//
//  MissedMedication.h
//  iStayHealthy
//
//  Created by peterschmidt on 15/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class iStayHealthyRecord;

@interface MissedMedication : NSManagedObject

@property (nonatomic, retain) NSString * UID;
@property (nonatomic, retain) NSString * Name;
@property (nonatomic, retain) NSDate * MissedDate;
@property (nonatomic, retain) NSString * Drug;
@property (nonatomic, retain) iStayHealthyRecord *record;

@end
