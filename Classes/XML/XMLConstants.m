//
//  XMLConstants.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 08/09/2012.
//
//

#import "XMLConstants.h"

NSString * const kXMLDBVersionString = @"14";
NSString * const kXMLPreamble = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
NSString * const kXMLElementRoot = @"iStayHealthyRecord";
NSString * const kXMLElementResults = @"Results";
NSString * const kXMLElementMedications = @"Medications";
NSString * const kXMLElementMissedMedications = @"MissedMedications";
NSString * const kXMLElementOtherMedications = @"OtherMedications";
NSString * const kXMLElementClinicalContacts = @"ClinicalContacts";
NSString * const kXMLElementIllnessAndProcedures = @"IllnessesAndProcedures";
NSString * const kXMLElementHIVSideEffects = @"HIVSideEffects";
NSString * const kXMLElementPreviousMedications = @"PreviousMedications";
NSString * const kXMLElementWellnesses = @"Wellnesses";

NSString * const kXMLElementResult = @"Result";
NSString * const kXMLElementMedication = @"Medication";
NSString * const kXMLElementMissedMedication = @"MissedMedication";
NSString * const kXMLElementOtherMedication = @"OtherMedication";
NSString * const kXMLElementContacts = @"Contacts";
NSString * const kXMLElementProcedures = @"Procedures";
NSString * const kXMLElementSideEffects = @"SideEffects";
NSString * const kXMLElementPreviousMedication = @"PreviousMedication";
NSString * const kXMLElementWellness = @"Wellness";

NSString * const kXMLAttributeFromDevice = @"fromDevice";
NSString * const kXMLAttributeFromDate = @"fromDate";
NSString * const kXMLAttributeDBVersion = @"dbVersion";
NSString * const kXMLAttributeMedicationForm = @"MedicationForm";
NSString * const kXMLAttributeName = @"Name";
NSString * const kXMLAttributeNameLowerCase = @"name";
NSString * const kXMLAttributeImage = @"Image";
NSString * const kXMLAttributeStartDate = @"StartDate";
NSString * const kXMLAttributeEndDate = @"EndDate";
NSString * const kXMLAttributeStartDateLowerCase = @"startDate";
NSString * const kXMLAttributeEndDateLowerCase = @"endDate";

NSString * const kXMLAttributeDose = @"Dose";
NSString * const kXMLAttributeUnit = @"Unit";
NSString * const kXMLAttributeMissedDate = @"MissedDate";
NSString * const kXMLAttributeDrug = @"Drug";
NSString * const kXMLAttributeDrugLowerCase = @"drug";
NSString * const kXMLAttributeCD4 = @"CD4";
NSString * const kXMLAttributeResultsDate = @"ResultsDate";
NSString * const kXMLAttributeViralLoad = @"ViralLoad";
NSString * const kXMLAttributeCD4Percent = @"CD4Percent";
NSString * const kXMLAttributeHepCViralLoad = @"HepCViralLoad";
NSString * const kXMLAttributeGlucose = @"Glucose";
NSString * const kXMLAttributeTotalCholesterol = @"TotalCholesterol";
NSString * const kXMLAttributeLDL = @"LDL";
NSString * const kXMLAttributeHDL = @"HDL";
NSString * const kXMLAttributeTriglyceride = @"Triglyceride";
NSString * const kXMLAttributeHeartRate = @"HeartRate";
NSString * const kXMLAttributeSystole = @"Systole";
NSString * const kXMLAttributeDiastole = @"Diastole";
NSString * const kXMLAttributeOxygenLevel = @"OxygenLevel";
NSString * const kXMLAttributeWeight = @"Weight";
NSString * const kXMLAttributeHemoglobulin = @"Hemoglobulin";
NSString * const kXMLAttributePlatelet = @"PlateletCount";
NSString * const kXMLAttributeWhiteBloodCells = @"WhiteBloodCellCount";
NSString * const kXMLAttributeRedBloodCells = @"redBloodCellCount";
NSString * const kXMLAttributeCholesterolRatio = @"cholesterolRatio";
NSString * const kXMLAttributeCardiacRiskFactor = @"cardiacRiskFactor";
NSString * const kXMLAttributeLiverAlanineTransaminase = @"liverAlanineTransaminase";
NSString * const kXMLAttributeLiverAspartateTransaminase = @"liverAspartateTransaminase";
NSString * const kXMLAttributeLiverAlkalinePhosphatase = @"liverAlkalinePhosphatase";
NSString * const kXMLAttributeLiverAlbumin = @"liverAlbumin";

NSString * const kXMLAttributeLiverAlanineTotalBilirubin = @"liverAlanineTotalBilirubin";
NSString * const kXMLAttributeLiverAlanineDirectBilirubin = @"liverAlanineDirectBilirubin";
NSString * const kXMLAttributeLiverGammaGlutamylTranspeptidase = @"liverGammaGlutamylTranspeptidase";
NSString * const kXMLAttributeUID = @"UID";
NSString * const kXMLAttributeUIDLowerCase = @"uID";
NSString * const kXMLAttributeClinicName = @"ClinicName";
NSString * const kXMLAttributeClinicID = @"ClinicID";
NSString * const kXMLAttributeClinicStreet = @"ClinicStreet";
NSString * const kXMLAttributeClinicPostcode = @"ClinicPostcode";

NSString * const kXMLAttributeClinicCity = @"ClinicCity";
NSString * const kXMLAttributeClinicContactNumber = @"ClinicContactNumber";
NSString * const kXMLAttributeResultsContactNumber = @"ResultsContactNumber";
NSString * const kXMLAttributeClinicEmailAddress = @"ClinicEmailAddress";
NSString * const kXMLAttributeClinicWebSite = @"ClinicWebSite";

NSString * const kXMLAttributeEmergencyContactNumber = @"EmergencyContactNumber";
NSString * const kXMLAttributeAppointmentContactNumber = @"AppointmentContactNumber";
NSString * const kXMLAttributeSideEffect = @"SideEffect";
NSString * const kXMLAttributeSideEffectDate = @"SideEffectDate";
NSString * const kXMLAttributeIllness = @"Illness";

NSString * const kXMLAttributeDate = @"Date";
NSString * const kXMLAttributeYearOfBirth = @"yearOfBirth";
NSString * const kXMLAttributeIsDiabetic = @"isDiabetic";
NSString * const kXMLAttributeIsSmoker = @"isSmoker";
NSString * const kXMLAttributeGender = @"gender";

NSString * const kXMLAttributeSleepBarometer = @"sleepBarometer";
NSString * const kXMLAttributeMoodBarometer = @"moodBarometer";
NSString * const kXMLAttributeWellnessBarometer = @"wellnessBarometer";
NSString * const kXMLAttributeMissedReason = @"missedReason";
NSString * const kXMLAttributeSeriousness = @"seriousness";
NSString * const kXMLAttributeReasonEnded = @"reasonEnded";
NSString * const kXMLAttributeIsART = @"isART";
