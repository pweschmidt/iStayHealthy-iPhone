//
//  Procedures.h
//  iStayHealthy
//
//  Created by peterschmidt on 20/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class iStayHealthyRecord;

@interface Procedures : NSManagedObject

@property (nonatomic, retain) NSString * Illness;
@property (nonatomic, retain) NSDate * Date;
@property (nonatomic, retain) NSDate * EndDate;
@property (nonatomic, retain) NSString * Name;
@property (nonatomic, retain) NSString * Notes;
@property (nonatomic, retain) NSString * CausedBy;
@property (nonatomic, retain) NSString * UID;
@property (nonatomic, retain) iStayHealthyRecord *record;

@end
