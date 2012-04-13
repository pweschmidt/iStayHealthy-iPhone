//
//  XMLDefinitions.h
//  iStayHealthy
//
//  Created by peterschmidt on 14/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef iStayHealthy_XMLDefinitions_h
#define iStayHealthy_XMLDefinitions_h

#define XMLPREAMBLE @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
//Container element definitions
#define ROOT @"iStayHealthyRecord"
#define RESULTS @"Results"
#define MEDICATIONS @"Medications"
#define MISSEDMEDICATIONS @"MissedMedications"
#define OTHERMEDICATIONS @"OtherMedications"
#define CLINICALCONTACTS @"ClinicalContacts"
#define ILLNESSANDPROCEDURES @"IllnessesAndProcedures"
#define HIVSIDEEFFECTS @"HIVSideEffects"

//Node Element definitions
#define RESULT @"Result"
#define MEDICATION @"Medication"
#define MISSEDMEDICATION @"MissedMedication"
#define OTHERMEDICATION @"OtherMedication"
#define CONTACTS @"Contacts"
#define SIDEEFFECTS @"SideEffects"
#define PROCEDURES @"Procedures"

//Attributes
#define FROMDEVICE @"fromDevice"
#define FROMDATE @"fromDate"
#define DBVERSION @"dbVersion"
#define MEDICATIONFORM @"MedicationForm"
#define NAME @"Name"
#define IMAGE @"Image"
#define ENDDATE @"EndDate"
#define STARTDATE @"StartDate"
#define DOSE @"Dose"
#define MISSEDDATE @"MissedDate"
#define DRUG @"Drug"
#define CD4COUNT @"CD4"
#define RESULTSDATE @"ResultsDate"
#define VIRALLOAD @"ViralLoad"
#define CD4PERCENT @"CD4Percent"
#define HEPCVIRALLOAD @"HepCViralLoad"
#define GLUCOSE @"Glucose"
#define TOTALCHOLESTEROL @"TotalCholesterol"
#define LDL @"LDL"
#define HDL @"HDL"
#define TRIGLYCERIDE @"Triglyceride"
#define HEARTRATE @"HeartRate"
#define SYSTOLE @"Systole"
#define DIASTOLE @"Diastole"
#define OXYGENLEVEL @"OxygenLevel"
#define WEIGHT @"Weight"
#define GUID @"UID"
#define CLINICNAME  @"ClinicName"
#define CLINICID @"ClinicID"
#define CLINICSTREET @"ClinicStreet"
#define CLINICPOSTCODE @"ClinicPostcode"
#define CLINICCITY @"ClinicCity"
#define CLINICCONTACTNUMBER @"ClinicContactNumber"
#define RESULTSCONTACTNUMBER @"ResultsContactNumber"
#define APPOINTMENTCONTACTNUMBER @"AppointmentContactNumber"
#define SIDEEFFECT @"SideEffect"
#define SIDEEFFECTDATE @"SideEffectDate"
#define ILLNESS @"Illness"
#define DATE @"Date"
#endif
