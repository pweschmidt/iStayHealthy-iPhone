//
//  Results.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 05/09/2012.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class iStayHealthyRecord;

@interface Results : NSManagedObject

@property (nonatomic, strong) NSNumber * LDL;
@property (nonatomic, strong) NSNumber * Hemoglobulin;
@property (nonatomic, strong) NSNumber * Glucose;
@property (nonatomic, strong) NSNumber * HeartRate;
@property (nonatomic, strong) NSNumber * CD4Percent;
@property (nonatomic, strong) NSDate * ResultsDate;
@property (nonatomic, strong) NSNumber * OxygenLevel;
@property (nonatomic, strong) NSString * UID;
@property (nonatomic, strong) NSNumber * Systole;
@property (nonatomic, strong) NSNumber * CD4;
@property (nonatomic, strong) NSNumber * PlateletCount;
@property (nonatomic, strong) NSNumber * HDL;
@property (nonatomic, strong) NSNumber * HepCViralLoad;
@property (nonatomic, strong) NSNumber * Weight;
@property (nonatomic, strong) NSNumber * Diastole;
@property (nonatomic, strong) NSNumber * WhiteBloodCellCount;
@property (nonatomic, strong) NSNumber * TotalCholesterol;
@property (nonatomic, strong) NSNumber * Triglyceride;
@property (nonatomic, strong) NSNumber * ViralLoad;
@property (nonatomic, strong) NSNumber * redBloodCellCount;
@property (nonatomic, strong) NSNumber * cholesterolRatio;
@property (nonatomic, strong) NSNumber * cardiacRiskFactor;
@property (nonatomic, strong) NSNumber * hepBTiter;
@property (nonatomic, strong) NSNumber * hepCTiter;
@property (nonatomic, strong) NSNumber * liverAlanineTransaminase;
@property (nonatomic, strong) NSNumber * liverAspartateTransaminase;
@property (nonatomic, strong) NSNumber * liverAlkalinePhosphatase;
@property (nonatomic, strong) NSNumber * liverAlbumin;
@property (nonatomic, strong) NSNumber * liverAlanineTotalBilirubin;
@property (nonatomic, strong) NSNumber * liverAlanineDirectBilirubin;
@property (nonatomic, strong) NSNumber * liverGammaGlutamylTranspeptidase;
@property (nonatomic, strong) iStayHealthyRecord *record;

@end
