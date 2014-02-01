//
//  SideEffects.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 01/02/2014.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class iStayHealthyRecord;

@interface SideEffects : NSManagedObject

@property (nonatomic, retain) NSString * UID;
@property (nonatomic, retain) NSDate * SideEffectDate;
@property (nonatomic, retain) NSString * Drug;
@property (nonatomic, retain) NSString * Name;
@property (nonatomic, retain) NSString * SideEffect;
@property (nonatomic, retain) NSString * seriousness;
@property (nonatomic, retain) NSString * frequency;
@property (nonatomic, retain) iStayHealthyRecord *record;

@end
