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

@property (nonatomic, strong) NSString * UID;
@property (nonatomic, strong) NSString * Name;
@property (nonatomic, strong) NSDate * MissedDate;
@property (nonatomic, strong) NSString * Drug;
@property (nonatomic, strong) iStayHealthyRecord *record;

@end
