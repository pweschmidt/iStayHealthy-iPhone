//
//  Results.h
//  iStayHealthy
//
//  Created by peterschmidt on 18/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class iStayHealthyRecord;

@interface Results : NSManagedObject

@property (nonatomic, retain) NSNumber * ViralLoad;
@property (nonatomic, retain) NSNumber * Systole;
@property (nonatomic, retain) NSNumber * HDL;
@property (nonatomic, retain) NSNumber * LDL;
@property (nonatomic, retain) NSNumber * Weight;
@property (nonatomic, retain) NSString * UID;
@property (nonatomic, retain) NSNumber * OxygenLevel;
@property (nonatomic, retain) NSNumber * CD4;
@property (nonatomic, retain) NSNumber * Diastole;
@property (nonatomic, retain) NSNumber * HeartRate;
@property (nonatomic, retain) NSDate * ResultsDate;
@property (nonatomic, retain) NSNumber * CD4Percent;
@property (nonatomic, retain) NSNumber * TotalCholesterol;
@property (nonatomic, retain) NSNumber * Triglyceride;
@property (nonatomic, retain) NSNumber * Glucose;
@property (nonatomic, retain) NSNumber * HepCViralLoad;
@property (nonatomic, retain) NSNumber * Hemoglobulin;
@property (nonatomic, retain) NSNumber * WhiteBloodCellCount;
@property (nonatomic, retain) NSNumber * PlateletCount;
@property (nonatomic, retain) iStayHealthyRecord *record;

@end
