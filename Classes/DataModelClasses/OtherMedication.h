//
//  OtherMedication.h
//  iStayHealthy
//
//  Created by peterschmidt on 18/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class iStayHealthyRecord;

@interface OtherMedication : NSManagedObject

@property (nonatomic, strong) NSString * UID;
@property (nonatomic, strong) NSNumber * Dose;
@property (nonatomic, strong) NSDate * StartDate;
@property (nonatomic, strong) NSDate * EndDate;
@property (nonatomic, strong) NSString * Name;
@property (nonatomic, strong) NSData * Image;
@property (nonatomic, strong) NSString * MedicationForm;
@property (nonatomic, strong) NSString * Unit;
@property (nonatomic, strong) iStayHealthyRecord *record;

@end
