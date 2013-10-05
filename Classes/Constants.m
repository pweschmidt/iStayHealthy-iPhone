//
//  Constants.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 29/08/2012.
//
//

#import "Constants.h"

NSString * const kAppNotificationKey = @"iStayHealthyNotification";
NSString * const kDefaultDateFormatting = @"dd-MMM-yy HH:mm:ss";
NSString * const kDefaultFontName = @"Helvetica";

NSString * const kDropboxConsumerKey = @"sekt4gbt7526j0y";;
NSString * const kDropboxSecretKey = @"drg5hompcf9vbd2";;

NSString * const kPKBConsumerKey = @"<replace with a valid key>";
NSString * const kPKBSecretKey = @"<replace with a valid key>";



NSString * const kMenuController = @"MenuController";
NSString * const kAddController = @"AddController";
NSString * const kResultsController = @"ResultsController";
NSString * const kDashboardController = @"DashboardController";
NSString * const kDropboxController = @"DropboxController";
NSString * const kHIVMedsController = @"MyHIVMedicationViewController";
NSString * const kAppointmentsController = @"AppointmentsController";
NSString * const kAlertsController = @"AlertsController";
NSString * const kClinicsController = @"ClinicsController";
NSString * const kOtherMedsController = @"OtherMedsController";
NSString * const kProceduresController = @"ProceduresController";
NSString * const kMissedController = @"MissedController";
NSString * const kSideEffectsController = @"SideEffectsController";
NSString * const kWellnessController = @"WellnessController";
NSString * const kInfoController = @"InfoController";
NSString * const kSettingsController = @"SettingsController";
NSString * const kMedicationDiaryController = @"MedicationDiaryController";
NSString * const kFeedbackController = @"FeedbackController";
NSString * const kEmailController = @"EmailController";



/**
 General
 */
NSString * const kUID = @"UID";
NSString * const kLastValueKey = @"lastValue";
NSString * const kPreviousValueKey = @"previousValue";
NSString * const kDifferentialKey = @"differential";
NSString * const kValueTypeKey = @"type";
NSString * const kHasResultsKey = @"hasResults";
NSString * const kResultsDictionaryKey = @"resultsDictionary";

/**
 XML
 */
NSString * const kXMLDBVersionString = @"14";
NSString * const kXMLPreamble = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
NSString * const kXMLElementRoot = @"iStayHealthyRecord";

/**
 Results
 */
NSString * const kResults = @"Results";
NSString * const kMedications = @"Medications";
NSString * const kMissedMedications = @"MissedMedications";
NSString * const kOtherMedications = @"OtherMedications";
NSString * const kClinicalContacts = @"ClinicalContacts";
NSString * const kIllnessAndProcedures = @"IllnessesAndProcedures";
NSString * const kHIVSideEffects = @"HIVSideEffects";
NSString * const kPreviousMedications = @"PreviousMedications";
NSString * const kWellnesses = @"Wellnesses";

NSString * const kResult = @"Result";
NSString * const kMedication = @"Medication";
NSString * const kMissedMedication = @"MissedMedication";
NSString * const kOtherMedication = @"OtherMedication";
NSString * const kContacts = @"Contacts";
NSString * const kProcedures = @"Procedures";
NSString * const kSideEffects = @"SideEffects";
NSString * const kPreviousMedication = @"PreviousMedication";
NSString * const kWellness = @"Wellness";

NSString * const kFromDevice = @"fromDevice";
NSString * const kFromDate = @"fromDate";
NSString * const kDBVersion = @"dbVersion";
NSString * const kMedicationForm = @"MedicationForm";
NSString * const kName = @"Name";
NSString * const kNameLowerCase = @"name";
NSString * const kImage = @"Image";
NSString * const kStartDate = @"StartDate";
NSString * const kEndDate = @"EndDate";
NSString * const kStartDateLowerCase = @"startDate";
NSString * const kEndDateLowerCase = @"endDate";

NSString * const kDose = @"Dose";
NSString * const kUnit = @"Unit";
NSString * const kMissedDate = @"MissedDate";
NSString * const kDrug = @"Drug";
NSString * const kDrugLowerCase = @"drug";
NSString * const kCD4 = @"CD4";
NSString * const kResultsDate = @"ResultsDate";
NSString * const kViralLoad = @"ViralLoad";
NSString * const kCD4Percent = @"CD4Percent";
NSString * const kHepCViralLoad = @"HepCViralLoad";
NSString * const kGlucose = @"Glucose";
NSString * const kTotalCholesterol = @"TotalCholesterol";
NSString * const kLDL = @"LDL";
NSString * const kHDL = @"HDL";
NSString * const kTriglyceride = @"Triglyceride";
NSString * const kHeartRate = @"HeartRate";
NSString * const kSystole = @"Systole";
NSString * const kDiastole = @"Diastole";
NSString * const kOxygenLevel = @"OxygenLevel";
NSString * const kWeight = @"Weight";
NSString * const kBMI = @"BMI";
NSString * const kHemoglobulin = @"Hemoglobulin";
NSString * const kPlatelet = @"PlateletCount";
NSString * const kWhiteBloodCells = @"WhiteBloodCellCount";
NSString * const kRedBloodCells = @"redBloodCellCount";
NSString * const kCholesterolRatio = @"cholesterolRatio";
NSString * const kCardiacRiskFactor = @"cardiacRiskFactor";
NSString * const kLiverAlanineTransaminase = @"liverAlanineTransaminase";
NSString * const kLiverAspartateTransaminase = @"liverAspartateTransaminase";
NSString * const kLiverAlkalinePhosphatase = @"liverAlkalinePhosphatase";
NSString * const kLiverAlbumin = @"liverAlbumin";
NSString * const kBloodPressure = @"BloodPressure";
NSString * const kLiverAlanineTotalBilirubin = @"liverAlanineTotalBilirubin";
NSString * const kLiverAlanineDirectBilirubin = @"liverAlanineDirectBilirubin";
NSString * const kLiverGammaGlutamylTranspeptidase = @"liverGammaGlutamylTranspeptidase";
NSString * const kUIDLowerCase = @"uID";
NSString * const kClinicName = @"ClinicName";
NSString * const kClinicID = @"ClinicID";
NSString * const kClinicStreet = @"ClinicStreet";
NSString * const kClinicPostcode = @"ClinicPostcode";

NSString * const kClinicCity = @"ClinicCity";
NSString * const kClinicContactNumber = @"ClinicContactNumber";
NSString * const kResultsContactNumber = @"ResultsContactNumber";
NSString * const kClinicEmailAddress = @"ClinicEmailAddress";
NSString * const kClinicWebSite = @"ClinicWebSite";

NSString * const kEmergencyContactNumber = @"EmergencyContactNumber";
NSString * const kAppointmentContactNumber = @"AppointmentContactNumber";

NSString * const kInsuranceID = @"InsuranceID";
NSString * const kInsuranceName = @"InsuranceName";
NSString * const kInsuranceWebSite = @"InsuranceWebSite";
NSString * const kClinicCountry = @"ClinicCountry";
NSString * const kConsultantName = @"ConsultantName";
NSString * const kInsuranceAuthorisationCode = @"InsuranceAuthorisationCode";
NSString * const kInsuranceContactNumber = @"InsuranceContactNumber";
NSString * const kEmergencyContactNumber2 = @"InsuranceContactNumber2";
NSString * const kClinicNurseName = @"ClinicNurseName";
NSString * const kContactName = @"ContactName";


NSString * const kSideEffect = @"SideEffect";
NSString * const kSideEffectDate = @"SideEffectDate";
NSString * const kIllness = @"Illness";

NSString * const kDate = @"Date";
NSString * const kYearOfBirth = @"yearOfBirth";
NSString * const kIsDiabetic = @"isDiabetic";
NSString * const kIsSmoker = @"isSmoker";
NSString * const kGender = @"gender";



NSString * const kSleepBarometer = @"sleepBarometer";
NSString * const kMoodBarometer = @"moodBarometer";
NSString * const kWellnessBarometer = @"wellnessBarometer";
NSString * const kMissedReason = @"missedReason";
NSString * const kSeriousness = @"seriousness";
NSString * const kReasonEnded = @"reasonEnded";
NSString * const kIsART = @"isART";
NSString * const kNotes = @"Notes";
NSString * const kCausedBy = @"CausedBy";
NSString * const kAlertLabel = @"AlertLabel";
NSString * const kAlertFrequency = @"AlertFrequency";
NSString * const kAlertSoundName = @"AlertSoundName";

NSString * const kMainDataSource    = @"iStayHealthy.sqlite";
NSString * const kBackupDataSource  = @"iStayHealthyBackup.sqlite";
NSString * const kiCloudDataSource  = @"iStayHealthyiCloud.sqlite";
NSString * const kFaultyDataSource  = @"iStayHealthyNoiCloud.sqlite";
NSString * const kUbiquitousKeyPath = @"5Y4HL833A4.com.pweschmidt.iStayHealthy.store";
NSString * const kTeamId            = @"5Y4HL833A4.com.pweschmidt.iStayHealthy";

NSString * const kDataTablesCleaned = @"dataTablesCleaned";
NSString * const kIsPasswordEnabled = @"isPasswordEnabled";
NSString * const kPassword = @"password";
NSString * const kPasswordTransferred = @"passwordIsTransferred";

NSString * const kResultsData = @"ResultsData";
NSString * const kMedicationData = @"MedicationData";
NSString * const kMissedMedicationData = @"MissedMedicationData";

NSString * const kSecretKey = @"EDFAEE24-CC9F-49FC-ADF6-FE2C8D2C313D";
NSString * const kImportXMLFile = @"importXML.isth";

NSString * const kMissedReasonForgotten = @"Forgotten";
NSString * const kMissedReasonNoMeds = @"Ran out of meds";
NSString * const kMissedReasonUnable = @"Could not take the pills";
NSString * const kMissedReasonUnwilling = @"Didn't want to take the meds";
NSString * const kMissedReasonOther = @"No particular reason";
NSString * const kEffectsOther = @"Select from list";
NSString * const kEffectsMinor = @"Minor";
NSString * const kEffectsMajor = @"Major";
NSString * const kEffectsSerious = @"Serious";
NSString * const kEffectsAlways = @"Always";
NSString * const kEffectsOften = @"Often";
NSString * const kEffectsSometimes = @"Sometimes";
NSString * const kEffectsRarely = @"Rarely";

