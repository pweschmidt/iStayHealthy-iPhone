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

@property (nonatomic, strong) NSString * Illness;
@property (nonatomic, strong) NSDate * Date;
@property (nonatomic, strong) NSDate * EndDate;
@property (nonatomic, strong) NSString * Name;
@property (nonatomic, strong) NSString * Notes;
@property (nonatomic, strong) NSString * CausedBy;
@property (nonatomic, strong) NSString * UID;
@property (nonatomic, strong) iStayHealthyRecord *record;

@end
