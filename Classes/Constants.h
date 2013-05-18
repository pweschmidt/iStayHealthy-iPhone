//
//  Constants.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 29/08/2012.
//
//

#import <Foundation/Foundation.h>

#define kNumberOfChartViews 14
#define APP_NAME [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]
#define SALT_HASH @"FvTivqTqZXsgLLx1v3P8TGRyVHaSOB1pvfm02wvGadj7RLHV8GrfxaZ84oGA8RsKdNRpxdAojXYg9iAj"
/**
 General
 */

extern NSString * const kUID;
extern NSString * const kLastValueKey;
extern NSString * const kPreviousValueKey;
extern NSString * const kDifferentialKey;
extern NSString * const kValueTypeKey;
extern NSString * const kHasResultsKey;
extern NSString * const kResultsDictionaryKey;
/**
 Results
 */
extern NSString * const kCD4;
extern NSString * const kCD4Percent;
extern NSString * const kViralLoad;
extern NSString * const kSystole;
extern NSString * const kHDL;
extern NSString * const kLDL;
extern NSString * const kWeight;
extern NSString * const kOxygenLevel;
extern NSString * const kDiastole;
extern NSString * const kHeartRate;
extern NSString * const kResultsDate;
extern NSString * const kTotalCholesterol;
extern NSString * const kTriglyceride;
extern NSString * const kGlucose;
extern NSString * const kHepCViralLoad;
extern NSString * const kWhiteBloodCellCount;
extern NSString * const kPlateletCount;
extern NSString * const kRedBloodCellCount;
extern NSString * const kHemoglobulin;


extern NSString * const kMainDataSource;
extern NSString * const kBackupDataSource;
extern NSString * const kiCloudDataSource;
extern NSString * const kFaultyDataSource;
extern NSString * const kUbiquitousKeyPath;
extern NSString * const kTeamId;
extern NSString * const kDataTablesCleaned;
extern NSString * const kIsPasswordEnabled;
extern NSString * const kPassword;
extern NSString * const kPasswordTransferred;

extern NSString * const kResultsData;
extern NSString * const kMedicationData;
extern NSString * const kMissedMedicationData;

extern NSString * const kSecretKey;
extern NSString * const kImportXMLFile;
