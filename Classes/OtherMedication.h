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

@property (nonatomic, retain) NSString * UID;
@property (nonatomic, retain) NSNumber * Dose;
@property (nonatomic, retain) NSDate * StartDate;
@property (nonatomic, retain) NSDate * EndDate;
@property (nonatomic, retain) NSString * Name;
@property (nonatomic, retain) NSData * Image;
@property (nonatomic, retain) NSString * MedicationForm;
@property (nonatomic, retain) NSString * Unit;
@property (nonatomic, retain) iStayHealthyRecord *record;

@end
