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

typedef NS_ENUM(int, DateType)
{
    DateOnly = 0,
    DateAndTime,
    TimeOnly
};

typedef NS_ENUM(int, ResultsType)
{
    HIVResultsType = 0,
    BloodResultsType,
    OtherResultsType
};

typedef NS_ENUM(int, InputType)
{
    DefaultInput = 0,
    NumericalInput,
    PercentageInput,
    BloodPressureInput,
    TextInput,
    EmailInput,
    WebInput
};

typedef NS_ENUM(int, FontType)
{
    Standard = 0,
    Light,
    LightItalic,
    Bold,
    BoldItalic
};

typedef NS_ENUM(int, FontSize)
{
    small = 10,
    medium = 12,
    standard = 15,
    large = 17
};


typedef NS_ENUM(int, MenuType)
{
    HamburgerMenuType = 0,
    AddMenuType
};

static NSUInteger DeviceSystemMajorVersion()
{
    static NSUInteger _deviceSystemMajorVersion = -1;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _deviceSystemMajorVersion = [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
    });
    
    return _deviceSystemMajorVersion;
}

#define EMBEDDED_DATE_PICKER (DeviceSystemMajorVersion() >= 7)



/**
 Block Definitions
 */
typedef void (^iStayHealthyErrorBlock)(NSError * error);
typedef void (^iStayHealthySuccessBlock)(BOOL success, NSError *error);
typedef void (^iStayHealthyArrayCompletionBlock)(NSArray *array, NSError *error);

/**
 General
 */
extern NSString * const kAppNotificationKey;
extern NSString * const kDefaultDateFormatting;
extern NSString * const kDateFormatting;
extern NSString * const kTimeFormatting;
extern NSString * const kDefaultFontName;
/**
 Dropbox app definitions
 */
extern NSString * const kDropboxConsumerKey;
extern NSString * const kDropboxSecretKey;

/**
 Patient Knows Best definitions
 */
extern NSString * const kPKBConsumerKey;
extern NSString * const kPKBSecretKey;

/**
 Controllers
 */
extern NSString * const kMenuController;
extern NSString * const kAddController;
extern NSString * const kResultsController;
extern NSString * const kDashboardController;
extern NSString * const kDropboxController;
extern NSString * const kHIVMedsController;
extern NSString * const kAppointmentsController;
extern NSString * const kAlertsController;
extern NSString * const kClinicsController;
extern NSString * const kOtherMedsController;
extern NSString * const kProceduresController;
extern NSString * const kMissedController;
extern NSString * const kSideEffectsController;
extern NSString * const kWellnessController;
extern NSString * const kInfoController;
extern NSString * const kSettingsController;
extern NSString * const kMedicationDiaryController;
extern NSString * const kFeedbackController;
extern NSString * const kEmailController;
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
 XML Specific
 */
extern NSString * const kXMLDBVersionString;
extern NSString * const kXMLPreamble;
extern NSString * const kXMLElementRoot;

/**
 Data
 */
extern NSString * const kResults;
extern NSString * const kMedications;
extern NSString * const kMissedMedications;
extern NSString * const kOtherMedications;
extern NSString * const kClinicalContacts;
extern NSString * const kIllnessAndProcedures;
extern NSString * const kHIVSideEffects;
extern NSString * const kPreviousMedications;
extern NSString * const kWellnesses;

extern NSString * const kResult;
extern NSString * const kMedication;
extern NSString * const kMissedMedication;
extern NSString * const kOtherMedication;
extern NSString * const kContacts;
extern NSString * const kProcedures;
extern NSString * const kSideEffects;
extern NSString * const kPreviousMedication;
extern NSString * const kWellness;

extern NSString * const kFromDevice;
extern NSString * const kFromDate;
extern NSString * const kDBVersion;
extern NSString * const kMedicationForm;
extern NSString * const kName;
extern NSString * const kNameLowerCase;
extern NSString * const kImage;
extern NSString * const kStartDate;
extern NSString * const kEndDate;
extern NSString * const kStartDateLowerCase;
extern NSString * const kEndDateLowerCase;

extern NSString * const kDose;
extern NSString * const kUnit;
extern NSString * const kMissedDate;
extern NSString * const kDrug;
extern NSString * const kDrugLowerCase;
extern NSString * const kCD4;
extern NSString * const kResultsDate;
extern NSString * const kViralLoad;
extern NSString * const kCD4Percent;
extern NSString * const kHepCViralLoad;
extern NSString * const kGlucose;
extern NSString * const kTotalCholesterol;
extern NSString * const kLDL;
extern NSString * const kHDL;
extern NSString * const kTriglyceride;
extern NSString * const kHeartRate;
extern NSString * const kSystole;
extern NSString * const kDiastole;
extern NSString * const kBloodPressure;
extern NSString * const kOxygenLevel;
extern NSString * const kWeight;
extern NSString * const kBMI;
extern NSString * const kHemoglobulin;
extern NSString * const kPlatelet;
extern NSString * const kWhiteBloodCells;
extern NSString * const kRedBloodCells;
extern NSString * const kCholesterolRatio;
extern NSString * const kCardiacRiskFactor;
extern NSString * const kLiverAlanineTransaminase;
extern NSString * const kLiverAspartateTransaminase;
extern NSString * const kLiverAlkalinePhosphatase;
extern NSString * const kLiverAlbumin;

extern NSString * const kLiverAlanineTotalBilirubin;
extern NSString * const kLiverAlanineDirectBilirubin;
extern NSString * const kLiverGammaGlutamylTranspeptidase;
extern NSString * const kUID;
extern NSString * const kUIDLowerCase;
extern NSString * const kClinicName;
extern NSString * const kClinicID;
extern NSString * const kClinicStreet;
extern NSString * const kClinicPostcode;

extern NSString * const kClinicCity;
extern NSString * const kClinicContactNumber;
extern NSString * const kResultsContactNumber;
extern NSString * const kClinicEmailAddress;
extern NSString * const kClinicWebSite;

extern NSString * const kEmergencyContactNumber;
extern NSString * const kAppointmentContactNumber;

extern NSString * const kInsuranceID;
extern NSString * const kInsuranceName;
extern NSString * const kInsuranceWebSite;
extern NSString * const kClinicCountry;
extern NSString * const kConsultantName;
extern NSString * const kInsuranceAuthorisationCode;
extern NSString * const kInsuranceContactNumber;
extern NSString * const kEmergencyContactNumber2;
extern NSString * const kClinicNurseName;
extern NSString * const kContactName;


extern NSString * const kSideEffect;
extern NSString * const kSideEffectDate;
extern NSString * const kIllness;

extern NSString * const kDate;
extern NSString * const kYearOfBirth;
extern NSString * const kIsDiabetic;
extern NSString * const kIsSmoker;
extern NSString * const kGender;

extern NSString * const kSleepBarometer;
extern NSString * const kMoodBarometer;
extern NSString * const kWellnessBarometer;
extern NSString * const kMissedReason;
extern NSString * const kSeriousness;
extern NSString * const kReasonEnded;
extern NSString * const kIsART;
extern NSString * const kNotes;
extern NSString * const kCausedBy;
extern NSString * const kAlertLabel;
extern NSString * const kAlertFrequency;
extern NSString * const kAlertSoundName;
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

extern NSString * const kMissedReasonForgotten;
extern NSString * const kMissedReasonNoMeds;
extern NSString * const kMissedReasonUnable;
extern NSString * const kMissedReasonUnwilling;
extern NSString * const kMissedReasonOther;
extern NSString * const kEffectsOther;
extern NSString * const kEffectsMinor;
extern NSString * const kEffectsMajor;
extern NSString * const kEffectsSerious;
extern NSString * const kEffectsAlways;
extern NSString * const kEffectsOften;
extern NSString * const kEffectsSometimes;
extern NSString * const kEffectsRarely;

extern NSString * const kAppointmentDate;
extern NSString * const kAppointmentClinic;
extern NSString * const kAppointmentNotes;
