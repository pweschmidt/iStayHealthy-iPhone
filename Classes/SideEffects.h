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

@property (nonatomic, strong) NSString * SideEffect;
@property (nonatomic, strong) NSDate * SideEffectDate;
@property (nonatomic, strong) NSString * Name;
@property (nonatomic, strong) NSString * UID;
@property (nonatomic, strong) NSString * Drug;
@property (nonatomic, strong) iStayHealthyRecord *record;

@end
