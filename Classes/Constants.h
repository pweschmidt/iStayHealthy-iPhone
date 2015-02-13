//
//  Constants.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 29/08/2012.
//
//

#import <Foundation/Foundation.h>


typedef void (^finishBlock)(void);

typedef NS_ENUM (NSUInteger, TransitionType)
{
    kMenuTransition = 0,
    kControllerTransition
};

typedef NS_ENUM (int, LoadedStore)
{
    MainStoreWithiCloud = 0,
    MainStoreWithoutiCloud,
    FallbackStore
};

typedef NS_ENUM (int, DateType)
{
    DateOnly = 0,
    DateAndTime,
    TimeOnly
};

typedef NS_ENUM (int, ResultsType)
{
    HIVResultsType = 0,
    BloodResultsType,
    OtherResultsType,
    LiverResultsType
};

typedef NS_ENUM (NSInteger, StorageType)
{
    isNewUser = 0,
    hasOldDataBaseFileNoBackupFile = 1,
    hasOldDataBaseAndBackupFile = 2,
    hasNewDataBaseFile = 3
};

typedef NS_ENUM (int, InputType)
{
    DefaultInput = 0,
    NumericalInput,
    PercentageInput,
    BloodPressureInput,
    TextInput,
    EmailInput,
    WebInput
};

typedef NS_ENUM (int, FontType)
{
    Standard = 0,
    Light,
    LightItalic,
    Bold,
    BoldItalic
};

typedef NS_ENUM (int, FontSize)
{
    veryTiny = 9,
    tiny = 10,
    small = 10,
    medium = 12,
    standard = 15,
    large = 17,
    xLarge = 20
};


typedef NS_ENUM (int, MenuType)
{
    HamburgerMenuType = 0,
    AddMenuType
};

// static NSUInteger DeviceSystemMajorVersion()
// {
//    static NSUInteger _deviceSystemMajorVersion = -1;
//    static dispatch_once_t onceToken;
//
//    dispatch_once(&onceToken, ^{
//                      _deviceSystemMajorVersion = [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
//                  });
//
//    return _deviceSystemMajorVersion;
// }

#define EMBEDDED_DATE_PICKER (DeviceSystemMajorVersion() >= 7)


@class iStayHealthyRecord;
/**
   Block Definitions
 */
typedef void (^iStayHealthyVoidExecutionBlock)(void);
typedef void (^iStayHealthyErrorBlock)(NSError *error);
typedef void (^iStayHealthyJSONDataBlock)(NSData *jsonData, NSError *error);
typedef void (^iStayHealthyJSONDictionaryBlock)(NSDictionary *jsonDictionary, NSError *error);
typedef void (^iStayHealthyXMLBlock)(NSString *xmlString, NSError *error);
typedef void (^iStayHealthySuccessBlock)(BOOL success, NSError *error);
typedef void (^iStayHealthyArrayCompletionBlock)(NSArray *array, NSError *error);
typedef void (^iStayHealthyRecordCompletionBlock)(iStayHealthyRecord *record, NSError *error);

/**
   General
 */
#define kAppNotificationKey               @"iStayHealthyNotification"
#define kAppNotificationIntervalKey       @"iStayHealthyNotificationInterval"
#define kDefaultDateFormatting            @"dd-MMM-yy HH:mm:ss"
#define kDateFormatting                   @"dd-MMM-yyyy"
#define kTimeFormatting                   @"HH:mm"
#define kDefaultFontName                  @"Helvetica"
#define kShortDateFormatting              @"MMM-yy"
#define kDiaryActivatedKey                @"MedicationDiaryActivate"
#define kDontShowWarning                  @"dontShowLoadWarning"
#define kIsVersionUpdate400               @"updatedToVersion400"
#define kIsVersionUpdate401               @"updatedToVersion401"
#define kStoreLoadingKey                  @"StoreLoaded"
#define kStoreUbiquityPathKey             @"RealUbiquityPath"
#define kImportNotificationKey            @"URLImportKey"
/**
   Database and iCloud
 */
#define kUbiquityCoreDataPath             @"CoreDataUbiquitySupport"
#define kLocalXMLBackupFile               @"iStayHealthyBackup.xml"
#define kNewSQLiteStore                   @"PWESiStayHealthy.sqlite"
#define kMainDataSource                   @"iStayHealthy.sqlite"
#define kBackupDataSource                 @"iStayHealthyBackup.sqlite"
#define kiCloudDataSource                 @"iStayHealthyiCloud.sqlite"
#define kFaultyDataSource                 @"iStayHealthyNoiCloud.sqlite"
#define kUbiquitousKeyPath                @"5Y4HL833A4.com.pweschmidt.iStayHealthy.store"
#define kTeamId                           @"5Y4HL833A4.com.pweschmidt.iStayHealthy"
#define kHouseKeeping                     @"HouseKeeping"
/**
   App and Dropbox app definitions
 */
#define APP_NAME                          [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]
#define SALT_HASH                         @"FvTivqTqZXsgLLx1v3P8TGRyVHaSOB1pvfm02wvGadj7RLHV8GrfxaZ84oGA8RsKdNRpxdAojXYg9iAj"
#define kDropboxConsumerKey               @"sekt4gbt7526j0y"
#define kDropboxSecretKey                 @"drg5hompcf9vbd2"


/**
   Controllers
 */
#define kDefaultControllerKey             @"DefaultController"
#define kMenuController                   @"MenuController"
#define kAddController                    @"AddController"
#define kResultsController                @"ResultsController"
#define kDashboardController              @"DashboardController"
#define kDropboxController                @"DropboxController"
#define kHIVMedsController                @"MyHIVMedicationViewController"
#define kAlertsController                 @"AlertsController"
#define kClinicsController                @"ClinicsController"
#define kOtherMedsController              @"OtherMedsController"
#define kProceduresController             @"ProceduresController"
#define kMissedController                 @"MissedController"
#define kSideEffectsController            @"SideEffectsController"
#define kWellnessController               @"WellnessController"
#define kInfoController                   @"InfoController"
#define kSettingsController               @"SettingsController"
#define kMedicationDiaryController        @"MedicationDiaryController"
#define kFeedbackController               @"FeedbackController"
#define kEmailController                  @"EmailController"
/**
   General
 */

#define kUID                              @"UID"
#define kLastValueKey                     @"lastValue"
#define kPreviousValueKey                 @"previousValue"
#define kDifferentialKey                  @"differential"
#define kValueTypeKey                     @"type"
#define kHasResultsKey                    @"hasResults"
#define kResultsDictionaryKey             @"resultsDictionary"

/**
   XML Specific
 */
#define kXMLDBVersionString               @"15"
#define kXMLPreamble                      @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
#define kXMLElementRoot                   @"iStayHealthyRecord"
#define kiStayHealthyClosingStatement     @"</iStayHealthyRecord>"
#define kiStayHealthyOpeningStatement     @"<iStayHealthyRecord"

/**
   XML Group elements
 */
#define kObservations                     @"Observations"
#define kNoResult                         @"NoResult"
#define kResults                          @"Results"
#define kMedications                      @"Medications"
#define kMissedMedications                @"MissedMedications"
#define kOtherMedications                 @"OtherMedications"
#define kClinicalContacts                 @"ClinicalContacts"
#define kIllnessAndProcedures             @"IllnessesAndProcedures"
#define kHIVSideEffects                   @"HIVSideEffects"
#define kPreviousMedications              @"PreviousMedications"
#define kWellnesses                       @"Wellnesses"
#define kSeinfeldCalendars                @"SeinfeldCalendars"
#define kSeinfeldCalendarEntries          @"SeinfeldCalendarEntries"

/**
   XML Nodes & Core Data Object class name
 */
#define kiStayHealthyRecord               @"iStayHealthyRecord"
#define kResult                           @"Result"
#define kMedication                       @"Medication"
#define kMissedMedication                 @"MissedMedication"
#define kOtherMedication                  @"OtherMedication"
#define kContacts                         @"Contacts"
#define kProcedures                       @"Procedures"
#define kSideEffects                      @"SideEffects"
#define kPreviousMedication               @"PreviousMedication"
#define kWellness                         @"Wellness"
#define kSeinfeldCalendar                 @"SeinfeldCalendar"
#define kSeinfeldCalendarEntry            @"SeinfeldCalendarEntry"

/**
   XML & Core Data Attribute names
 */
#define kFromDevice                       @"fromDevice"
#define kFromDate                         @"fromDate"
#define kDBVersion                        @"dbVersion"
#define kMedicationForm                   @"MedicationForm"
#define kName                             @"Name"
#define kNameLowerCase                    @"name"
#define kImage                            @"Image"
#define kStartDate                        @"StartDate"
#define kEndDate                          @"EndDate"
#define kStartDateLowerCase               @"startDate"
#define kEndDateLowerCase                 @"endDate"

#define kDose                             @"Dose"
#define kUnit                             @"Unit"
#define kMissedDate                       @"MissedDate"
#define kDrug                             @"Drug"
#define kDrugLowerCase                    @"drug"
#define kCD4                              @"CD4"
#define kResultsDate                      @"ResultsDate"
#define kViralLoad                        @"ViralLoad"
#define kCD4Percent                       @"CD4Percent"
#define kHepCViralLoad                    @"HepCViralLoad"
#define kGlucose                          @"Glucose"
#define kTotalCholesterol                 @"TotalCholesterol"
#define kLDL                              @"LDL"
#define kHDL                              @"HDL"
#define kTriglyceride                     @"Triglyceride"
#define kHeartRate                        @"HeartRate"
#define kSystole                          @"Systole"
#define kDiastole                         @"Diastole"
#define kBloodPressure                    @"BloodPressure"
#define kOxygenLevel                      @"OxygenLevel"
#define kWeight                           @"Weight"
#define kBMI                              @"bmi"
#define kHemoglobulin                     @"Hemoglobulin"
#define kPlatelet                         @"PlateletCount"
#define kWhiteBloodCells                  @"WhiteBloodCellCount"
#define kRedBloodCells                    @"redBloodCellCount"
#define kCholesterolRatio                 @"cholesterolRatio"
#define kCardiacRiskFactor                @"cardiacRiskFactor"
#define kLiverAlanineTransaminase         @"liverAlanineTransaminase"
#define kLiverAspartateTransaminase       @"liverAspartateTransaminase"
#define kLiverAlkalinePhosphatase         @"liverAlkalinePhosphatase"
#define kLiverAlbumin                     @"liverAlbumin"

#define kLiverAlanineTotalBilirubin       @"liverAlanineTotalBilirubin"
#define kLiverAlanineDirectBilirubin      @"liverAlanineDirectBilirubin"
#define kLiverGammaGlutamylTranspeptidase @"liverGammaGlutamylTranspeptidase"
#define kUIDLowerCase                     @"uID"
#define kClinicName                       @"ClinicName"
#define kClinicID                         @"ClinicID"
#define kClinicStreet                     @"ClinicStreet"
#define kClinicPostcode                   @"ClinicPostcode"

#define kClinicCity                       @"ClinicCity"
#define kClinicContactNumber              @"ClinicContactNumber"
#define kResultsContactNumber             @"ResultsContactNumber"
#define kClinicEmailAddress               @"ClinicEmailAddress"
#define kClinicWebSite                    @"ClinicWebSite"

#define kEmergencyContactNumber           @"EmergencyContactNumber"
#define kAppointmentContactNumber         @"AppointmentContactNumber"

#define kInsuranceID                      @"InsuranceID"
#define kInsuranceName                    @"InsuranceName"
#define kInsuranceWebSite                 @"InsuranceWebSite"
#define kClinicCountry                    @"ClinicCountry"
#define kConsultantName                   @"ConsultantName"
#define kInsuranceAuthorisationCode       @"InsuranceAuthorisationCode"
#define kInsuranceContactNumber           @"InsuranceContactNumber"
#define kEmergencyContactNumber2          @"InsuranceContactNumber2"
#define kClinicNurseName                  @"ClinicNurseName"
#define kContactName                      @"ContactName"


#define kSideEffect                       @"SideEffect"
#define kSideEffectDate                   @"SideEffectDate"
#define kIllness                          @"Illness"

#define kDate                             @"Date"
#define kYearOfBirth                      @"yearOfBirth"
#define kIsDiabetic                       @"isDiabetic"
#define kIsSmoker                         @"isSmoker"
#define kGender                           @"gender"

#define kIsCompleted                      @"isCompleted"
#define kDateLowerCase                    @"date"
#define kHasTakenMeds                     @"hasTakenMeds"
#define kScore                            @"score"
#define kEntries                          @"entries"

#define kSleepBarometer                   @"sleepBarometer"
#define kMoodBarometer                    @"moodBarometer"
#define kWellnessBarometer                @"wellnessBarometer"
#define kMissedReason                     @"missedReason"
#define kSeriousness                      @"seriousness"
#define kReasonEnded                      @"reasonEnded"
#define kIsART                            @"isART"
#define kNotes                            @"Notes"
#define kCausedBy                         @"CausedBy"
#define kAlertLabel                       @"AlertLabel"
#define kAlertFrequency                   @"AlertFrequency"
#define kAlertSoundName                   @"AlertSoundName"


/**
   General String definitions
 */
#define kDataTablesCleaned                @"dataTablesCleaned"
#define kIsPasswordEnabled                @"isPasswordEnabled"
#define kPassword                         @"password"
#define kPasswordTransferred              @"passwordIsTransferred"
#define kPasswordReset                    @"resetPassword"
#define kDashboardTypes                   @"dashboardTypes"
#define kCD4AndVL                         @"CD4AndVL"
#define kCD4PercentAndVL                  @"CD4PercentAndVL"

#define kResultsData                      @"ResultsData"
#define kMedicationData                   @"MedicationData"
#define kMissedMedicationData             @"MissedMedicationData"

#define kSecretKey                        @"EDFAEE24-CC9F-49FC-ADF6-FE2C8D2C313D"
#define kImportXMLFile                    @"importXML.isth"

#define kMissedReasonForgotten            @"Forgotten"
#define kMissedReasonNoMeds               @"Ran out of meds"
#define kMissedReasonUnable               @"Could not take the pills"
#define kMissedReasonUnwilling            @"Didn't want to take the meds"
#define kMissedReasonOther                @"No particular reason"
#define kEffectsOther                     @"Select from list"
#define kEffectsMinor                     @"Minor"
#define kEffectsMajor                     @"Major"
#define kEffectsSerious                   @"Serious"
#define kEffectsAlways                    @"Always"
#define kEffectsOften                     @"Often"
#define kEffectsSometimes                 @"Sometimes"
#define kEffectsRarely                    @"Rarely"



#define kAppointmentDate                  @"AppointmentDate"
#define kAppointmentClinic                @"AppointmentClinic"
#define kAppointmentNotes                 @"AppointmentNotes"
#define kSystoleFieldTag                  9999
#define kDiastoleFieldTag                 9998

/**
   Colour definitions
 */
#define TEXTCOLOUR                        [UIColor colorWithRed:51.0 / 255.0 green:102.0 / 255.0 blue:204.0 / 255.0 alpha:1.0]
#define DARK_YELLOW                       [UIColor colorWithRed:255.0 / 255.0 green:152.0 / 255.0 blue:0.0 / 255.0 alpha:1.0]
#define DARK_GREEN                        [UIColor colorWithRed:0.0 / 255.0 green:102.0 / 255.0 blue:0.0 / 255.0 alpha:1.0]
#define DARK_RED                          [UIColor colorWithRed:204.0 / 255.0 green:0.0 / 255.0 blue:0.0 / 255.0 alpha:1.0]
#define BACKGROUND_EVEN                   [UIColor colorWithRed:224.0 / 255.0 green:255.0 / 255.0 blue:255.0 / 255.0 alpha:1.0]
#define BACKGROUND_ODD                    [UIColor colorWithRed:173.0 / 255.0 green:224.0 / 255.0 blue:255.0 / 255.0 alpha:1.0]
#define DEFAULT_BACKGROUND                [UIColor colorWithRed:253.0 / 255.0 green:255.0 / 255.0 blue:240.0 / 255.0 alpha:1.0]
#define MENU_BACKGROUND                   [UIColor colorWithRed:243.0 / 255.0 green:255.0 / 255.0 blue:230.0 / 255.0 alpha:1.0]
#define TINTCOLOUR                        [UIColor colorWithRed:236.0 / 255.0 green:153.0 / 255.0 blue:51.0 / 255.0 alpha:1.0]

#define DARK_BLUE                         [UIColor colorWithRed:0.0 / 255.0 green:0.0 / 255.0 blue:102.0 / 255.0 alpha:1.0]
#define CD4COLOUR                         [UIColor colorWithRed:255.0 / 255.0 green:255.0 / 255.0 blue:102.0 / 255.0 alpha:1.0]
#define VIRALLOADCOLOUR                   [UIColor colorWithRed:255.0 / 255.0 green:0.0 / 255.0 blue:102.0 / 255.0 alpha:1.0]
#define AXISCOLOUR                        [UIColor whiteColor]
#define BRIGHT_BACKGROUND                 [UIColor colorWithRed:255.0 / 255.0 green:255.0 / 255.0 blue:255. / 255.0 alpha:1.0]
#define kDarkBackgroundColor              [UIColor colorWithRed:0.435294 green:0.443137 blue:0.47451 alpha:1]
#define kShadingColour                    [UIColor colorWithRed:235.0f / 255.0f green:235.0f / 255.0f blue:235.0f / 255.0f alpha:0.8]

#define kDefaultFont                      @"HelveticaNeue"
#define kDefaultLightFont                 @"HelveticaNeue-Light"
#define kDefaultUltraLightFont            @"HelveticaNeue-UltraLight"
#define kDefaultBoldFont                  @"HelveticaNeue-Bold"
#define kDefaultItalicFont                @"HelveticaNeue-LightOblique"
#define kDefaultBoldItalicFont            @"HelveticaNeue-BoldOblique"


/**
   Dashboard definitions
 */
#define kPlotAxisTickLabelExpFontSize     @"AxisTickExpSize"
#define kPlotAxisTitleFontSize            @"AxisTitleFontSize"
#define kPlotAxisTickLabelFontSize        @"AxisTickFontSize"
#define kPlotAxisTitleFontName            @"AxisFontname"
#define kPlotAxisTickFontName             @"AxisTickFontName"
#define kPlotAxisTickDistance             @"TickDistance"


#define kNumberOfChartViews               14
#define kDaysOfMedicationsMarginInPlot    7

#define kEnlargeFactor                    1.25
#define kZoomFactor                       0.80
