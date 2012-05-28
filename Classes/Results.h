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

@property (nonatomic, strong) NSNumber * ViralLoad;
@property (nonatomic, strong) NSNumber * Systole;
@property (nonatomic, strong) NSNumber * HDL;
@property (nonatomic, strong) NSNumber * LDL;
@property (nonatomic, strong) NSNumber * Weight;
@property (nonatomic, strong) NSString * UID;
@property (nonatomic, strong) NSNumber * OxygenLevel;
@property (nonatomic, strong) NSNumber * CD4;
@property (nonatomic, strong) NSNumber * Diastole;
@property (nonatomic, strong) NSNumber * HeartRate;
@property (nonatomic, strong) NSDate * ResultsDate;
@property (nonatomic, strong) NSNumber * CD4Percent;
@property (nonatomic, strong) NSNumber * TotalCholesterol;
@property (nonatomic, strong) NSNumber * Triglyceride;
@property (nonatomic, strong) NSNumber * Glucose;
@property (nonatomic, strong) NSNumber * HepCViralLoad;
@property (nonatomic, strong) NSNumber * Hemoglobulin;
@property (nonatomic, strong) NSNumber * WhiteBloodCellCount;
@property (nonatomic, strong) NSNumber * PlateletCount;
@property (nonatomic, strong) iStayHealthyRecord *record;

@end
