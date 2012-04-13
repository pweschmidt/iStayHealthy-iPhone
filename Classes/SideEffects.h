//
//  SideEffects.h
//  iStayHealthy
//
//  Created by peterschmidt on 20/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class iStayHealthyRecord;

@interface SideEffects : NSManagedObject

@property (nonatomic, retain) NSString * SideEffect;
@property (nonatomic, retain) NSDate * SideEffectDate;
@property (nonatomic, retain) NSString * Name;
@property (nonatomic, retain) NSString * UID;
@property (nonatomic, retain) NSString * Drug;
@property (nonatomic, retain) iStayHealthyRecord *record;

@end
