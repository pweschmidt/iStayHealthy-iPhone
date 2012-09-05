//
//  SideEffects.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 05/09/2012.
//
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
@property (nonatomic, strong) NSString * seriousness;
@property (nonatomic, strong) iStayHealthyRecord *record;

@end
