//
//  SQLBackupStoreManager.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 26/10/2012.
//
//

#import "SQLBackupStoreManager.h"
#import "Utilities.h"
#import "iStayHealthyRecord.h"
#import "NSArray-Set.h"
#import "Wellness.h"
#import "PreviousMedication.h"
#import "Results.h"
#import "Procedures.h"
#import "SideEffects.h"
#import "MissedMedication.h"
#import "OtherMedication.h"
#import "Medication.h"
#import "Contacts.h"
#import "Constants.h"

@interface SQLBackupStoreManager ()
@property (nonatomic, strong, readwrite) NSManagedObjectModel *model;
@property (nonatomic, strong, readwrite) NSURL *mainStoreURL;
@property (nonatomic, strong, readwrite) NSURL *backupStoreURL;
@property (nonatomic, strong, readwrite) NSDictionary *localOptions;
@property (nonatomic, strong, readwrite) NSOperationQueue *mainQueue;
- (BOOL)backupStoreExists;
- (BOOL)removeBackupStoreIfExists:(NSError *__autoreleasing *)error;

- (void)addResult:(Results *)result record:(iStayHealthyRecord *)record context:(NSManagedObjectContext *)context;
- (void)addHIVMed:(Medication *)med record:(iStayHealthyRecord *)record context:(NSManagedObjectContext *)context;
- (void)addPreviousMed:(PreviousMedication *)med record:(iStayHealthyRecord *)record context:(NSManagedObjectContext *)context;
- (void)addOtherMed:(OtherMedication *)med record:(iStayHealthyRecord *)record context:(NSManagedObjectContext *)context;
- (void)addMissedMed:(MissedMedication *)med record:(iStayHealthyRecord *)record context:(NSManagedObjectContext *)context;
- (void)addSideEffect:(SideEffects *)effect record:(iStayHealthyRecord *)record context:(NSManagedObjectContext *)context;
- (void)addContact:(Contacts *)contact record:(iStayHealthyRecord *)record context:(NSManagedObjectContext *)context;
- (void)addProcedure:(Procedures *)procedure record:(iStayHealthyRecord *)record context:(NSManagedObjectContext *)context;
- (void)addWellness:(Wellness *)wellness record:(iStayHealthyRecord *)record context:(NSManagedObjectContext *)context;

@end

@implementation SQLBackupStoreManager
@synthesize model = _model;
@synthesize mainStoreURL = _mainStoreURL;
@synthesize backupStoreURL = _backupStoreURL;
@synthesize localOptions = _localOptions;
@synthesize mainQueue = _mainQueue;

- (id)init
{
    self = [super init];
    if (nil != self)
    {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"iStayHealthy"
                                                  withExtension:@"momd"];
        self.model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        NSURL *documentsDirectory = [[[NSFileManager defaultManager]
                                      URLsForDirectory:NSDocumentDirectory
                                      inDomains:NSUserDomainMask] lastObject];
        self.mainStoreURL = [documentsDirectory URLByAppendingPathComponent:kMainDataSource];
        self.backupStoreURL = [documentsDirectory URLByAppendingPathComponent:kBackupDataSource];
        self.localOptions = [NSDictionary
                             dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],
                             NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES],
                             NSInferMappingModelAutomaticallyOption, nil];
        self.mainQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void)transferDataToBackupStore
{
    [self.mainQueue addOperationWithBlock:^{
        NSError *error = nil;
        [self removeBackupStoreIfExists:&error];
        
        
        NSPersistentStoreCoordinator *originalPSC = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.model];
        
        
        
        NSDictionary *seedStoreOptions = @{ NSReadOnlyPersistentStoreOption : [NSNumber numberWithBool:YES] };
        
        NSPersistentStore *mainStore = [originalPSC addPersistentStoreWithType:NSSQLiteStoreType
                                                             configuration:nil
                                                                       URL:self.mainStoreURL
                                                                   options:seedStoreOptions
                                                                     error:&error];
        

        NSPersistentStoreCoordinator *migratedPSC = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.model];

        NSDictionary *dbStoreOptions = [NSDictionary
                                        dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],
                                        NSMigratePersistentStoresAutomaticallyOption,
                                        [NSNumber numberWithBool:YES],
                                        NSInferMappingModelAutomaticallyOption, nil];
        
        NSPersistentStore *backupStore = [migratedPSC addPersistentStoreWithType:NSSQLiteStoreType
                                                                   configuration:nil
                                                                             URL:self.backupStoreURL
                                                                         options:dbStoreOptions
                                                                           error:&error];
        if (mainStore && backupStore)
        {
            NSError *fetchError = nil;
            NSManagedObjectContext *seedContext = [[NSManagedObjectContext alloc] init];
            [seedContext setPersistentStoreCoordinator:originalPSC];
            NSFetchRequest *fetchRequest = [NSFetchRequest
                                            fetchRequestWithEntityName:@"iStayHealthyRecord"];

            NSArray *records = [seedContext executeFetchRequest:fetchRequest error:&fetchError];
            BOOL isReadyForTransfer = NO;
            if (nil != records)
            {
                if (0 < records.count)
                {
                    isReadyForTransfer = YES;
                }
                
            }
            if (isReadyForTransfer)
            {
                NSManagedObjectContext *backupContext = [[NSManagedObjectContext alloc]
                                                         initWithConcurrencyType:NSPrivateQueueConcurrencyType];
                [backupContext setPersistentStoreCoordinator:migratedPSC];
                iStayHealthyRecord *record = (iStayHealthyRecord *)[records lastObject];
                NSEntityDescription *newEntity = [record entity];
                iStayHealthyRecord *newMasterRecord = [[iStayHealthyRecord alloc] initWithEntity:newEntity insertIntoManagedObjectContext:backupContext];
                newMasterRecord.Name = record.Name;
                newMasterRecord.isPasswordEnabled = record.isPasswordEnabled;
                newMasterRecord.Password = record.Password;
                newMasterRecord.UID = record.UID;
                newMasterRecord.isSmoker = record.isSmoker;
                newMasterRecord.gender = record.gender;
                newMasterRecord.yearOfBirth = record.yearOfBirth;
                newMasterRecord.isDiabetic = record.isDiabetic;

                for (Contacts *contacts in record.contacts)
                {
                    [self addContact:contacts record:newMasterRecord context:backupContext];
                }
                for (Results *results in record.results)
                {
                    [self addResult:results record:newMasterRecord context:backupContext];
                }
                for (MissedMedication *missed in record.missedMedications)
                {
                    [self addMissedMed:missed record:newMasterRecord context:backupContext];
                }
                for (Medication *med in record.medications)
                {
                    [self addHIVMed:med record:newMasterRecord context:backupContext];
                }
                for (OtherMedication *med in record.otherMedications)
                {
                    [self addOtherMed:med record:newMasterRecord context:backupContext];
                }
                for (PreviousMedication *med in record.previousMedications)
                {
                    [self addPreviousMed:med record:newMasterRecord context:backupContext];
                }
                for (SideEffects *effects in record.sideeffects)
                {
                    [self addSideEffect:effects record:newMasterRecord context:backupContext];
                }
                for (Procedures *procs in record.procedures)
                {
                    [self addProcedure:procs record:newMasterRecord context:backupContext];
                }
                for (Wellness *well in record.wellness)
                {
                    [self addWellness:well record:newMasterRecord context:backupContext];
                }
                [backupContext assignObject:newMasterRecord toPersistentStore:backupStore];
                BOOL success = [backupContext save:&error];
                if (success)
                {
                    [backupContext reset];
                }
                
            }
            
        }
    }];
}

///TODO: we need to be EXTREMELY careful when transferring the data from the
// backup store to the iCloud store. We don't want to duplicate all records, just the
// ones we added while iCloud was inoperatives
- (void)transferDataFromBackupStore:(NSPersistentStoreCoordinator *)cloudCoordinator
{
    if (![self backupStoreExists])
    {
        return;
    }

    [self.mainQueue addOperationWithBlock:^{
        NSError *error = nil;
        NSPersistentStoreCoordinator *originalPSC = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.model];
        
        
        
        NSDictionary *seedStoreOptions = @{ NSReadOnlyPersistentStoreOption : [NSNumber numberWithBool:YES] };
        
        NSPersistentStore *backupStore = [originalPSC addPersistentStoreWithType:NSSQLiteStoreType
                                                                 configuration:nil
                                                                           URL:self.backupStoreURL
                                                                       options:seedStoreOptions
                                                                         error:&error];
        NSPersistentStore *cloudStore = [cloudCoordinator persistentStoreForURL:self.mainStoreURL];
        if (backupStore && cloudStore)
        {
            
        }
    }];
}


- (BOOL)removeBackupStoreIfExists:(NSError *__autoreleasing *)error
{
    if (![self backupStoreExists])
    {
        return YES;
    }

    NSFileManager *fileManager = [[NSFileManager alloc] init];
    BOOL success = [fileManager removeItemAtPath:[self.backupStoreURL path] error:error];

#ifdef APPDEBUG
    if (success)
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSLog(@"the deletion of the backupstore was successful");
        }];
    }
    else
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSLog(@"the deletion of the backupstore failed.");
        }];
    }
#endif
    
    return success;
}

- (BOOL)backupStoreExists
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if ([fileManager fileExistsAtPath:[self.backupStoreURL path]])
    {
       return YES;
    }
    return NO;
}



#pragma private methods to add the content of a master record to a new context
/**
 Results
 */
- (void)addResult:(Results *)result record:(iStayHealthyRecord *)record context:(NSManagedObjectContext *)context
{
    Results *copiedResult = [NSEntityDescription insertNewObjectForEntityForName:@"Results" inManagedObjectContext:context];
    [record addResultsObject:copiedResult];
    copiedResult.UID = result.UID;
    copiedResult.ResultsDate = result.ResultsDate;
    copiedResult.CD4 = result.CD4;
    copiedResult.CD4Percent = result.CD4Percent;
    copiedResult.ViralLoad = result.ViralLoad;
    copiedResult.HepCViralLoad = result.HepCViralLoad;
    copiedResult.Hemoglobulin = result.Hemoglobulin;
    copiedResult.WhiteBloodCellCount = result.WhiteBloodCellCount;
    copiedResult.redBloodCellCount = result.redBloodCellCount;
    copiedResult.PlateletCount = result.PlateletCount;
    
    copiedResult.Glucose = result.Glucose;
    copiedResult.cholesterolRatio = result.cholesterolRatio;
    copiedResult.TotalCholesterol = result.TotalCholesterol;
    copiedResult.Triglyceride = result.Triglyceride;
    copiedResult.HDL = result.HDL;
    copiedResult.LDL = result.LDL;
    
    copiedResult.Weight = result.Weight;
    copiedResult.Systole = result.Systole;
    copiedResult.Diastole = result.Diastole;
    
    copiedResult.HeartRate = result.HeartRate;
    copiedResult.hepBTiter = result.hepBTiter;
    copiedResult.hepCTiter = result.hepCTiter;
    copiedResult.liverAlanineDirectBilirubin = result.liverAlanineDirectBilirubin;
    copiedResult.liverAlanineTotalBilirubin = result.liverAlanineTotalBilirubin;
    copiedResult.liverAlanineTransaminase = result.liverAlanineTransaminase;
    copiedResult.liverAlbumin = result.liverAlbumin;
    copiedResult.liverAlkalinePhosphatase = result.liverAlkalinePhosphatase;
    copiedResult.liverAspartateTransaminase = result.liverAspartateTransaminase;
    copiedResult.liverGammaGlutamylTranspeptidase = result.liverGammaGlutamylTranspeptidase;
}

/**
 Medication
 */
- (void)addHIVMed:(Medication *)med record:(iStayHealthyRecord *)record context:(NSManagedObjectContext *)context
{
    Medication *copiedMed = [NSEntityDescription insertNewObjectForEntityForName:@"Medication" inManagedObjectContext:context];
    [record addMedicationsObject:copiedMed];
    copiedMed.UID = med.UID;
    copiedMed.StartDate = med.StartDate;
    copiedMed.Name = med.Name;
    copiedMed.Dose = med.Dose;
    copiedMed.Drug = med.Drug;
    copiedMed.MedicationForm = med.MedicationForm;
}

/**
 Previous Medication
 */
- (void)addPreviousMed:(PreviousMedication *)med record:(iStayHealthyRecord *)record context:(NSManagedObjectContext *)context
{
    PreviousMedication *copiedMed = [NSEntityDescription
                                     insertNewObjectForEntityForName:@"PreviousMedication"
                                     inManagedObjectContext:context];
    [record addPreviousMedicationsObject:copiedMed];
    copiedMed.uID = med.uID;
    copiedMed.startDate = med.startDate;
    copiedMed.endDate = med.endDate;
    copiedMed.name = med.name;
    copiedMed.drug = med.drug;
    copiedMed.isART = med.isART;
    copiedMed.reasonEnded = med.reasonEnded;
}

/**
 Other Medication
 */
- (void)addOtherMed:(OtherMedication *)med record:(iStayHealthyRecord *)record context:(NSManagedObjectContext *)context
{
    OtherMedication *copiedMed = [NSEntityDescription
                                  insertNewObjectForEntityForName:@"OtherMedication"
                                  inManagedObjectContext:context];
    [record addOtherMedicationsObject:copiedMed];
    copiedMed.UID = med.UID;
    copiedMed.Unit = med.Unit;
    copiedMed.StartDate = med.StartDate;
    copiedMed.EndDate = med.EndDate;
    copiedMed.Name = med.Name;
    copiedMed.Dose = med.Dose;
    copiedMed.MedicationForm = med.MedicationForm;
    copiedMed.Image = med.Image;
}

/**
 Missed Medication
 */
- (void)addMissedMed:(MissedMedication *)med record:(iStayHealthyRecord *)record context:(NSManagedObjectContext *)context
{
    MissedMedication *copiedMed = [NSEntityDescription
                                   insertNewObjectForEntityForName:@"MissedMedication"
                                   inManagedObjectContext:context];
    [record addMissedMedicationsObject:copiedMed];
    copiedMed.UID = med.UID;
    copiedMed.missedReason = med.missedReason;
    copiedMed.MissedDate = med.MissedDate;
    copiedMed.Name = med.Name;
    copiedMed.Drug = med.Drug;
}

/**
 Side Effects
 */
- (void)addSideEffect:(SideEffects *)effect record:(iStayHealthyRecord *)record context:(NSManagedObjectContext *)context
{
    SideEffects *copiedEffect = [NSEntityDescription
                                 insertNewObjectForEntityForName:@"SideEffects"
                                 inManagedObjectContext:context];
    [record addSideeffectsObject:copiedEffect];
    copiedEffect.UID = effect.UID;
    copiedEffect.SideEffect = effect.SideEffect;
    copiedEffect.SideEffectDate = effect.SideEffectDate;
    copiedEffect.seriousness = effect.seriousness;
    copiedEffect.Name = effect.Name;
    copiedEffect.Drug = effect.Drug;
}

/**
 Contacts
 */
- (void)addContact:(Contacts *)contact record:(iStayHealthyRecord *)record context:(NSManagedObjectContext *)context
{
    Contacts *copiedContact = [NSEntityDescription
                               insertNewObjectForEntityForName:@"Contacts"
                               inManagedObjectContext:context];
    [record addContactsObject:copiedContact];
    copiedContact.UID = contact.UID;
    copiedContact.ClinicCity = contact.ClinicCity;
    copiedContact.ClinicContactNumber = contact.ClinicContactNumber;
    copiedContact.ClinicCountry = contact.ClinicCountry;
    copiedContact.ClinicEmailAddress = contact.ClinicEmailAddress;
    copiedContact.ClinicID = contact.ClinicID;
    copiedContact.ClinicName = contact.ClinicName;
    copiedContact.ClinicNurseName = contact.ClinicNurseName;
    copiedContact.ClinicPostcode = contact.ClinicPostcode;
    copiedContact.ClinicStreet = contact.ClinicStreet;
    copiedContact.ClinicWebSite = contact.ClinicWebSite;
    copiedContact.ConsultantName = contact.ConsultantName;
    copiedContact.ContactName = contact.ContactName;
    copiedContact.AppointmentContactNumber = contact.AppointmentContactNumber;
    copiedContact.EmergencyContactNumber = contact.EmergencyContactNumber;
    copiedContact.EmergencyContactNumber2 = contact.EmergencyContactNumber2;
    copiedContact.InsuranceAuthorisationCode = contact.InsuranceAuthorisationCode;
    copiedContact.InsuranceContactNumber = contact.InsuranceContactNumber;
    copiedContact.InsuranceID = contact.InsuranceID;
    copiedContact.InsuranceName = contact.InsuranceName;
    copiedContact.InsuranceWebSite = contact.InsuranceWebSite;
    copiedContact.ResultsContactNumber = contact.ResultsContactNumber;
}

/**
 Procedures & Illness
 */
- (void)addProcedure:(Procedures *)procedure record:(iStayHealthyRecord *)record context:(NSManagedObjectContext *)context
{
    Procedures *copiedProcedure = [NSEntityDescription
                                   insertNewObjectForEntityForName:@"Procedures"
                                   inManagedObjectContext:context];
    [record addProceduresObject:copiedProcedure];
    copiedProcedure.UID = procedure.UID;
    copiedProcedure.Date = procedure.Date;
    copiedProcedure.Illness = procedure.Illness;
    copiedProcedure.Name = procedure.Name;
    copiedProcedure.Notes = procedure.Notes;
    copiedProcedure.EndDate = procedure.EndDate;
    copiedProcedure.CausedBy = procedure.CausedBy;
}

/**
 Wellness
 */
- (void)addWellness:(Wellness *)wellness record:(iStayHealthyRecord *)record context:(NSManagedObjectContext *)context
{
    Wellness *copiedWellness = [NSEntityDescription
                                insertNewObjectForEntityForName:@"Wellness"
                                inManagedObjectContext:context];
    [record addWellnessObject:copiedWellness];
    copiedWellness.uID = wellness.uID;
    copiedWellness.sleepBarometer = wellness.sleepBarometer;
    copiedWellness.moodBarometer = wellness.moodBarometer;
    copiedWellness.wellnessBarometer = wellness.wellnessBarometer;
}
@end
