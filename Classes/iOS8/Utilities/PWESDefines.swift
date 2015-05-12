//
//  PWESDefines.swift
//  iStayHealthy
//
//  Created by Peter_Schmidt on 10/01/2015.
//
//

import Foundation
import UIKit

typealias PWESSuccessWithDictionaryClosure = (success: Bool, dictionary: NSDictionary?, error: NSError?) -> Void
typealias PWESArrayClosure = (array: NSArray?, error: NSError?) -> Void

typealias PWESSuccessClosure = (success: Bool, error: NSError?) -> Void

let kDefaultBackground = UIColor(red: 253.0/255.0, green: 1.0, blue: 240.0/255.0, alpha: 1.0)
let kDarkGreen =  UIColor(red:0.0 / 255.0, green:102.0 / 255.0, blue:0.0 / 255.0, alpha:1.0)
let kDarkRed =    UIColor(red:204.0 / 255.0, green:0.0 / 255.0, blue:0.0 / 255.0, alpha:1.0)
let kTextColour =  UIColor(red:51.0 / 255.0, green:102.0 / 255.0, blue:204.0 / 255.0, alpha:1.0)
let kUbiquitousPath                   = "5Y4HL833A4.com.pweschmidt.iStayHealthy.store"
let kICloudTeamID                     = "5Y4HL833A4.com.pweschmidt.iStayHealthy"
let kBackgroundQueueName              = "com.pweschmidt.iStayHealthy.background.queue"
let kLoadedStoreNotificationKey       = "LoadedStore"
let kImportedDataFromFileKey          = "ImportedData"
let kErrorStoreNotificationKey        = "ErrorLoadingStore"
let kErrorImportFromFileKey           = "ErrorImportingFile"
let kManageData                       = "ManageData?"
let kManageDataOptions                = "ManageDataOptions"
let kChangeiCloud                     = "ChangeiCloud"
let kDisable_iCloud                   = "Disable_iCloud"
let kRecoverLocally                   = "RecoverLocally"
let kRecoverDropbox                   = "RecoverDropbox"
let kOpenSettings                     = "OpenSettings"
let kOpeniCloud                       = "OpeniCloud"
let kSelectiStayHealthy               = "SelectiStayHealthy"
let kChangeSwitch                     = "ChangeSwitch"
let kRestartApp                       = "RestartApp"
let kOpenLocalBackup                  = "OpenLocalBackup"
let kCheckiCloudEnabled               = "CheckiCloudEnabled"
let kSelectRecoverLocally             = "SelectRecoverLocally"
let kSelectDropboxIcon                = "SelectDropboxIcon"
let kSelectRestore                    = "SelectRestore"


/**
XML Group elements
*/
let kObservations                     = "Observations"
let kNoResult                         = "NoResult"
let kResults                          = "Results"
let kMedications                      = "Medications"
let kMissedMedications                = "MissedMedications"
let kOtherMedications                 = "OtherMedications"
let kClinicalContacts                 = "ClinicalContacts"
let kIllnessAndProcedures             = "IllnessesAndProcedures"
let kHIVSideEffects                   = "HIVSideEffects"
let kPreviousMedications              = "PreviousMedications"
let kWellnesses                       = "Wellnesses"
let kSeinfeldCalendars                = "SeinfeldCalendars"
let kSeinfeldCalendarEntries          = "SeinfeldCalendarEntries"

/**
XML Nodes & Core Data Object class name
*/
let kiStayHealthyRecord               = "iStayHealthyRecord"
let kResult                           = "Result"
let kMedication                       = "Medication"
let kMissedMedication                 = "MissedMedication"
let kOtherMedication                  = "OtherMedication"
let kContacts                         = "Contacts"
let kProcedures                       = "Procedures"
let kSideEffects                      = "SideEffects"
let kPreviousMedication               = "PreviousMedication"
let kWellness                         = "Wellness"
let kSeinfeldCalendar                 = "SeinfeldCalendar"
let kSeinfeldCalendarEntry            = "SeinfeldCalendarEntry"

/**
XML & Core Data Attribute names
*/
let kFromDevice                       = "fromDevice"
let kFromDate                         = "fromDate"
let kDBVersion                        = "dbVersion"
let kMedicationForm                   = "MedicationForm"
let kName                             = "Name"
let kNameLowerCase                    = "name"
let kImage                            = "Image"
let kStartDate                        = "StartDate"
let kEndDate                          = "EndDate"
let kStartDateLowerCase               = "startDate"
let kEndDateLowerCase                 = "endDate"

let kDose                             = "Dose"
let kUnit                             = "Unit"
let kMissedDate                       = "MissedDate"
let kDrug                             = "Drug"
let kDrugLowerCase                    = "drug"
let kCD4                              = "CD4"
let kResultsDate                      = "ResultsDate"
let kViralLoad                        = "ViralLoad"
let kCD4Percent                       = "CD4Percent"
let kHepCViralLoad                    = "HepCViralLoad"
let kGlucose                          = "Glucose"
let kTotalCholesterol                 = "TotalCholesterol"
let kLDL                              = "LDL"
let kHDL                              = "HDL"
let kTriglyceride                     = "Triglyceride"
let kHeartRate                        = "HeartRate"
let kSystole                          = "Systole"
let kDiastole                         = "Diastole"
let kBloodPressure                    = "BloodPressure"
let kOxygenLevel                      = "OxygenLevel"
let kWeight                           = "Weight"
let kBMI                              = "bmi"
let kHemoglobulin                     = "Hemoglobulin"
let kPlatelet                         = "PlateletCount"
let kWhiteBloodCells                  = "WhiteBloodCellCount"
let kRedBloodCells                    = "redBloodCellCount"
let kCholesterolRatio                 = "cholesterolRatio"
let kCardiacRiskFactor                = "cardiacRiskFactor"
let kLiverAlanineTransaminase         = "liverAlanineTransaminase"
let kLiverAspartateTransaminase       = "liverAspartateTransaminase"
let kLiverAlkalinePhosphatase         = "liverAlkalinePhosphatase"
let kLiverAlbumin                     = "liverAlbumin"
let kKidneyGFR                        = "kidneyGFR"

let kLiverAlanineTotalBilirubin       = "liverAlanineTotalBilirubin"
let kLiverAlanineDirectBilirubin      = "liverAlanineDirectBilirubin"
let kLiverGammaGlutamylTranspeptidase = "liverGammaGlutamylTranspeptidase"
let kUIDLowerCase                     = "uID"
let kClinicName                       = "ClinicName"
let kClinicID                         = "ClinicID"
let kClinicStreet                     = "ClinicStreet"
let kClinicPostcode                   = "ClinicPostcode"

let kClinicCity                       = "ClinicCity"
let kClinicContactNumber              = "ClinicContactNumber"
let kResultsContactNumber             = "ResultsContactNumber"
let kClinicEmailAddress               = "ClinicEmailAddress"
let kClinicWebSite                    = "ClinicWebSite"

let kEmergencyContactNumber           = "EmergencyContactNumber"
let kAppointmentContactNumber         = "AppointmentContactNumber"

let kInsuranceID                      = "InsuranceID"
let kInsuranceName                    = "InsuranceName"
let kInsuranceWebSite                 = "InsuranceWebSite"
let kClinicCountry                    = "ClinicCountry"
let kConsultantName                   = "ConsultantName"
let kInsuranceAuthorisationCode       = "InsuranceAuthorisationCode"
let kInsuranceContactNumber           = "InsuranceContactNumber"
let kEmergencyContactNumber2          = "InsuranceContactNumber2"
let kClinicNurseName                  = "ClinicNurseName"
let kContactName                      = "ContactName"


let kSideEffect                       = "SideEffect"
let kSideEffectDate                   = "SideEffectDate"
let kIllness                          = "Illness"

let kDate                             = "Date"
let kYearOfBirth                      = "yearOfBirth"
let kIsDiabetic                       = "isDiabetic"
let kIsSmoker                         = "isSmoker"
let kGender                           = "gender"

let kIsCompleted                      = "isCompleted"
let kDateLowerCase                    = "date"
let kHasTakenMeds                     = "hasTakenMeds"
let kScore                            = "score"
let kEntries                          = "entries"

let kSleepBarometer                   = "sleepBarometer"
let kMoodBarometer                    = "moodBarometer"
let kWellnessBarometer                = "wellnessBarometer"
let kMissedReason                     = "missedReason"
let kSeriousness                      = "seriousness"
let kReasonEnded                      = "reasonEnded"
let kIsART                            = "isART"
let kNotes                            = "Notes"
let kCausedBy                         = "CausedBy"
let kAlertLabel                       = "AlertLabel"
let kAlertFrequency                   = "AlertFrequency"
let kAlertSoundName                   = "AlertSoundName"


