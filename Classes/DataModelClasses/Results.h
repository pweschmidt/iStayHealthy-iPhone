//
//  Results.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 03/01/2014.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class iStayHealthyRecord;

@interface Results : NSManagedObject

@property (nonatomic, retain) NSNumber * WhiteBloodCellCount;
@property (nonatomic, retain) NSNumber * liverAlanineTransaminase;
@property (nonatomic, retain) NSNumber * LDL;
@property (nonatomic, retain) NSNumber * liverAspartateTransaminase;
@property (nonatomic, retain) NSNumber * ViralLoad;
@property (nonatomic, retain) NSNumber * Hemoglobulin;
@property (nonatomic, retain) NSNumber * Glucose;
@property (nonatomic, retain) NSNumber * HeartRate;
@property (nonatomic, retain) NSNumber * CD4Percent;
@property (nonatomic, retain) NSNumber * liverAlkalinePhosphatase;
@property (nonatomic, retain) NSDate * ResultsDate;
@property (nonatomic, retain) NSNumber * liverAlbumin;
@property (nonatomic, retain) NSNumber * OxygenLevel;
@property (nonatomic, retain) NSString * UID;
@property (nonatomic, retain) NSNumber * liverAlanineTotalBilirubin;
@property (nonatomic, retain) NSNumber * cholesterolRatio;
@property (nonatomic, retain) NSNumber * hepBTiter;
@property (nonatomic, retain) NSNumber * redBloodCellCount;
@property (nonatomic, retain) NSNumber * Systole;
@property (nonatomic, retain) NSNumber * hepCTiter;
@property (nonatomic, retain) NSNumber * CD4;
@property (nonatomic, retain) NSNumber * PlateletCount;
@property (nonatomic, retain) NSNumber * HDL;
@property (nonatomic, retain) NSNumber * cardiacRiskFactor;
@property (nonatomic, retain) NSNumber * HepCViralLoad;
@property (nonatomic, retain) NSNumber * Triglyceride;
@property (nonatomic, retain) NSNumber * TotalCholesterol;
@property (nonatomic, retain) NSNumber * Weight;
@property (nonatomic, retain) NSNumber * liverGammaGlutamylTranspeptidase;
@property (nonatomic, retain) NSNumber * Diastole;
@property (nonatomic, retain) NSNumber * liverAlanineDirectBilirubin;
@property (nonatomic, retain) NSNumber * bmi;
@property (nonatomic, retain) iStayHealthyRecord *record;

@end
