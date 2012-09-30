//
//  SQLiteHelper.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 29/09/2012.
//
//

#import "SQLiteHelper.h"
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

NSString * const kSQLiteiCloudStore = @"iStayHealthy.sqlite";
NSString * const kSQLiteNoiCloudStore = @"iStayHealthyNoiCloud.sqlite";


@interface SQLiteHelper ()
@property (nonatomic, strong, readwrite) NSPersistentStoreCoordinator * persistentStoreCoordinator;
@property (nonatomic, strong, readwrite) NSManagedObjectContext * mainObjectContext;
@property (nonatomic, strong, readwrite) NSManagedObjectContext * localObjectContext;
@property (nonatomic, strong, readwrite) NSURL * storeURL;
@property (nonatomic, strong, readwrite) NSURL * noiCloudStoreURL;
@property (nonatomic, strong, readwrite) NSOperationQueue * mainQueue;
@property (nonatomic, strong, readwrite) NSLock * universalLock;
@property (nonatomic, strong, readwrite) id currentUbiquityToken;
@property (nonatomic, strong, readwrite) NSPersistentStore * noniCloudStore;
@property (nonatomic, strong, readwrite) NSDictionary * localStoreOptions;
@property BOOL useLocalStore;
- (void)setUpCoordinatorAndContext;
- (BOOL)loadLocalSQLiteStore:(NSError *__autoreleasing *)error;
- (BOOL)loadSQLiteStoreFromiCloud:(NSError *__autoreleasing *)error;
- (NSURL *)applicationDocumentsDirectory;
- (void)setUpNoniCloudStore;
- (void)addMasterRecordWithObjectContext:(NSManagedObjectContext *)context;
- (void)transferDataToLocalStore;
- (void)addResult:(Results *)result store:(NSPersistentStore *)store context:(NSManagedObjectContext *)context;
- (void)addHIVMed:(Medication *)med store:(NSPersistentStore *)store context:(NSManagedObjectContext *)context;
- (void)addPreviousMed:(PreviousMedication *)med store:(NSPersistentStore *)store context:(NSManagedObjectContext *)context;
- (void)addOtherMed:(OtherMedication *)med store:(NSPersistentStore *)store context:(NSManagedObjectContext *)context;
- (void)addMissedMed:(MissedMedication *)med store:(NSPersistentStore *)store context:(NSManagedObjectContext *)context;
- (void)addSideEffect:(SideEffects *)effect store:(NSPersistentStore *)store context:(NSManagedObjectContext *)context;
- (void)addContact:(Contacts *)contact store:(NSPersistentStore *)store context:(NSManagedObjectContext *)context;
- (void)addProcedure:(Procedures *)procedure store:(NSPersistentStore *)store context:(NSManagedObjectContext *)context;
- (void)addWellness:(Wellness *)wellness store:(NSPersistentStore *)store context:(NSManagedObjectContext *)context;
- (void)mergeChangesFrom_iCloud:(NSNotification *)notification;
@end


@implementation SQLiteHelper
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize mainObjectContext = _mainObjectContext;
@synthesize storeURL = _storeURL;
@synthesize mainQueue = _mainQueue;
@synthesize universalLock = _universalLock;
@synthesize noiCloudStoreURL = _noiCloudStoreURL;
@synthesize currentUbiquityToken = _currentUbiquityToken;
@synthesize noniCloudStore = _noniCloudStore;
@synthesize localStoreOptions = _localStoreOptions;
@synthesize useLocalStore = _useLocalStore;
@synthesize localObjectContext = _localObjectContext;
/**
 init sets up the managedobject context and the non iCloud store
 */
- (id)init
{
    self = [super init];
    if (nil != self)
    {
        self.mainQueue = [[NSOperationQueue alloc] init];
        self.universalLock = [[NSLock alloc] init];
        self.useLocalStore = NO;
        [self setUpCoordinatorAndContext];
        [self setUpNoniCloudStore];
    }
    return self;
}

/**
 this starts the async operation to load the persistent stores for either local (Simulator only) or
 iCloud. Always 2 stores are being loaded: the actual store (i.e. iCloud) iStayHealthy.sqlite and the 
 backup store, iStayHealthyNoiCloud.sqlite
 */
- (void)loadSQLitePersistentStore
{
#ifdef APPDEBUG
    NSLog(@"SQLiteHelper:loadSQLitePersistentStore ENTERING");
#endif
    __weak SQLiteHelper *weakSelf = self;
    [self.mainQueue addOperationWithBlock:^{
        BOOL locked = NO;
        @try
        {
            [weakSelf.universalLock lock];
            locked = YES;
            NSError *error;
            if (DEVICE_IS_SIMULATOR)
            {
                [weakSelf loadLocalSQLiteStore:&error];
            }
            else
            {
                [weakSelf loadSQLiteStoreFromiCloud:&error];
            }    
        } @finally
        {
            if (locked)
            {
                [weakSelf.universalLock unlock];
                locked = NO;
            }
        }
        
    }];
    
}


#pragma mark - private methods

/**
 called first when initialising. This sets up the main object context on the main thread, the
 persistentstorecoordinator, the URLs for both iCloud store (which is the same as the local store for Simulator)
 and the non iCloud Store. This method is being called on the main thread.
 We also setup the store options for non-cloud.
 NOTE: we do not create the persistent stores themselves here. This is done asynchronously in a separate step.
 */

- (void)setUpCoordinatorAndContext
{
#ifdef APPDEBUG
    NSLog(@"SQLiteHelper:setUpCoordinatorAndContext ENTERING");
#endif
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"iStayHealthy" withExtension:@"momd"];
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    self.mainObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [self.mainObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];

    self.storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:kSQLiteiCloudStore];

    self.noiCloudStoreURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:kSQLiteNoiCloudStore];
#ifdef APPDEBUG
    NSLog(@"store URL = %@ and fallback store URL is %@", [self.storeURL path], [self.noiCloudStoreURL path]);
#endif
    
    self.localStoreOptions = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0"))
    {
        self.currentUbiquityToken = [[NSFileManager defaultManager] ubiquityIdentityToken];
    }
#ifdef APPDEBUG
    NSLog(@"SQLiteHelper:setUpCoordinatorAndContext LEAVING");
#endif

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mergeChangesFrom_iCloud:)
                                                 name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
                                               object:self.persistentStoreCoordinator];
}

/**
 This is the second call in the initialiser.
 Here we set up the backup/non-iCloud store. Since this store is ALWAYS local on the device we can create the store
 straightaway. 
 */
- (void)setUpNoniCloudStore
{
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"iStayHealthy" withExtension:@"momd"];
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSPersistentStoreCoordinator *storeCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    NSError *error = nil;
    NSPersistentStore *store = [storeCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                              configuration:nil
                                                                        URL:self.noiCloudStoreURL
                                                                    options:self.localStoreOptions
                                                                      error:&error];
    if (nil != store)
    {
#ifdef APPDEBUG
        NSLog(@"SQLiteHelper:setUpNoniCloudStore we created the fallback store");
#endif
        self.noniCloudStore = store;
        self.localObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [self.localObjectContext setPersistentStoreCoordinator:storeCoordinator];
    }
    else
    {
#ifdef APPDEBUG
        NSLog(@"SQLiteHelper:setUpNoniCloudStore we were NOT successful to create the fallback store");
#endif
        self.noniCloudStore = nil;
    }    
    
}

- (void)mergeChangesFrom_iCloud:(NSNotification *)notification
{
    [self.mainObjectContext performBlock:^{
        [self.mainObjectContext mergeChangesFromContextDidSaveNotification:notification];
        NSNotification* refreshNotification = [NSNotification notificationWithName:@"RefetchAllDatabaseData"
                                                                            object:self
                                                                          userInfo:[notification userInfo]];
        [[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
    }];
}


/**
 This method is only called when running in the simulator. It uses the same name for the SQLite database as it is used
 for iCloud.
 */
- (BOOL)loadLocalSQLiteStore:(NSError *__autoreleasing *)error
{
#ifdef APPDEBUG
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSLog(@"SQLiteHelper:loadLocalSQLiteStore ENTERING");
    }];
#endif
    NSPersistentStore *localStore = [self.persistentStoreCoordinator
                                     addPersistentStoreWithType:NSSQLiteStoreType
                                     configuration:nil
                                     URL:self.storeURL
                                     options:self.localStoreOptions
                                     error:error];
    if (nil == localStore)
    {
        abort();
    }
    else
    {
        [self addMasterRecordWithObjectContext:self.mainObjectContext];
        [self addMasterRecordWithObjectContext:self.localObjectContext];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSLog(@"SQLiteHelper:loadLocalSQLiteStore we now got the store");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RefetchAllDatabaseData" object:self userInfo:nil];
        }];
    }
    return YES;
    
}


/**
 This is the heart and core of SQLiteHelper.
 We first check the availability of iCloud. If available, we create the store using the cloud options. If that fails, or if
 iCloud (ubiquityContainer) is not available, we then create the non-iCloud Store instead. 
 However, if we do succeed creating the iCloud store, we then call onto a method that checks whether the fallback store is empty.
 If yes, we then copy all material from the current iCloud store over to the non-iCloud store to have a snapshot from the moment
 the app is started.
 
 */
- (BOOL)loadSQLiteStoreFromiCloud:(NSError *__autoreleasing *)error
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSURL *ubiquityContainer = [fileManager URLForUbiquityContainerIdentifier:nil];
    BOOL useNoniCloudStore = NO;
    if (nil != ubiquityContainer)
    {
        NSString* coreDataCloudContent = [[ubiquityContainer path] stringByAppendingPathComponent:@"data"];
        
        NSURL *amendedCloudURL = [NSURL fileURLWithPath:coreDataCloudContent];
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                                 @"5Y4HL833A4.com.pweschmidt.iStayHealthy.store", NSPersistentStoreUbiquitousContentNameKey,
                                 amendedCloudURL, NSPersistentStoreUbiquitousContentURLKey,
                                 nil];
        NSError *error = nil;
        NSPersistentStore *cloudStore = [self.persistentStoreCoordinator
                                         addPersistentStoreWithType:NSSQLiteStoreType
                                         configuration:nil
                                         URL:self.storeURL
                                         options:options
                                         error:&error];
        if (nil == cloudStore)
        {
            useNoniCloudStore = YES;
        }
        else
        {
            [self addMasterRecordWithObjectContext:self.mainObjectContext];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RefetchAllDatabaseData" object:self userInfo:nil];
            }];            
        }
        
    }
    if (useNoniCloudStore)
    {
        NSError *error = nil;
        NSPersistentStore *localStore = [self.persistentStoreCoordinator
                                         addPersistentStoreWithType:NSSQLiteStoreType
                                         configuration:nil
                                         URL:self.noiCloudStoreURL
                                         options:self.localStoreOptions
                                         error:&error];
        if (nil == localStore)
        {
            abort();
        }
        else
        {
            [self addMasterRecordWithObjectContext:self.mainObjectContext];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RefetchAllDatabaseData" object:self userInfo:nil];
            }];
        }
    }
    return YES;
}

/**
 gets the URL to the directory where we store the SQLite databases
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

/**
 This method ensures that we always have a master record available.
 The master record contains relationships to all other records. Only 1 can ever be present.
 */
- (void)addMasterRecordWithObjectContext:(NSManagedObjectContext *)context
{
#ifdef APPDEBUG
    NSLog(@"SQLiteHelper:addMasterRecordWithObjectContext ENTERING");
#endif
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"iStayHealthyRecord"];
    NSArray *records = [context executeFetchRequest:fetchRequest error:&error];
    if (nil != records)
    {
        if (0 == records.count)
        {
            NSManagedObject *newRecord = [NSEntityDescription insertNewObjectForEntityForName:@"iStayHealthyRecord"
                                                                       inManagedObjectContext:context];
            [newRecord setValue:@"YourName" forKey:@"Name"];
            BOOL success = [context save:&error];
            if (!success)
            {
#ifdef APPDEBUG
                NSLog(@"SQLiteHelper:addMasterRecordWithObjectContext we could not save a master Record to the store");
#endif
            }
            
        }
#ifdef APPDEBUG
        else
        {
            NSLog(@"SQLiteHelper:addMasterRecordWithObjectContext we already have 1 master record in the store");            
        }
#endif
    }    
}


/**
 a rather big method - as we transfer all data records to the local store
 */
- (void)transferDataToLocalStore
{
    if (nil == self.noniCloudStore)
    {
        return;
    }
    NSError *error = nil;
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    [context setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"iStayHealthyRecord"];
    NSArray *records = [context executeFetchRequest:fetchRequest error:&error];

    if (nil == records)
    {
        return;
    }

    if (0 == records.count)
    {
        return;
    }

    NSManagedObjectContext *subContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    NSPersistentStoreCoordinator *localCoordinator = [self.noniCloudStore persistentStoreCoordinator];
    [subContext setPersistentStoreCoordinator:localCoordinator];
    [self addMasterRecordWithObjectContext:subContext];
    
    iStayHealthyRecord *record = (iStayHealthyRecord *)[records objectAtIndex:0];
    NSArray *results = [record.results allObjects];
    NSArray *hivMeds = [record.medications allObjects];
    NSArray *meds = [record.otherMedications allObjects];
    NSArray *effects = [record.sideeffects allObjects];
    NSArray *missed = [record.missedMedications allObjects];
    NSArray *procs = [record.procedures allObjects];
    NSArray *contacts = [record.contacts allObjects];
    NSArray *previous = [record.previousMedications allObjects];
    NSArray *wellness = [record.wellness allObjects];
    BOOL success = YES;
    for (Results *result in results)
    {
        [self addResult:result store:self.noniCloudStore context:subContext];
        success = [subContext save:&error];
        if (!success)
        {
            break;
        }
    }
    for (Medication *hivmed in hivMeds)
    {
        [self addHIVMed:hivmed store:self.noniCloudStore context:subContext];
        success = [subContext save:&error];
        if (!success)
        {
            break;
        }
    }
    for (OtherMedication *med in meds)
    {
        [self addOtherMed:med store:self.noniCloudStore context:subContext];
        success = [subContext save:&error];
        if (!success)
        {
            break;
        }
    }
    for (SideEffects *effect in effects)
    {
        [self addSideEffect:effect store:self.noniCloudStore context:subContext];
        success = [subContext save:&error];
        if (!success)
        {
            break;
        }
    }
    for (MissedMedication *mis in missed)
    {
        [self addMissedMed:mis store:self.noniCloudStore context:subContext];
        success = [subContext save:&error];
        if (!success)
        {
            break;
        }
    }
    for (Procedures *proc in procs)
    {
        [self addProcedure:proc store:self.noniCloudStore context:subContext];
        success = [subContext save:&error];
        if (!success)
        {
            break;
        }
    }
    for (Contacts *contact in contacts)
    {
        [self addContact:contact store:self.noniCloudStore context:subContext];
        success = [subContext save:&error];
        if (!success)
        {
            break;
        }
    }
    for (PreviousMedication *old in previous)
    {
        [self addPreviousMed:old store:self.noniCloudStore context:subContext];
        success = [subContext save:&error];
        if (!success)
        {
            break;
        }
    }
    for (Wellness *well in wellness)
    {
        [self addWellness:well store:self.noniCloudStore context:subContext];
        success = [subContext save:&error];
        if (!success)
        {
            break;
        }
    }
    if ([subContext hasChanges])
    {
        success = [subContext save:&error];
        if (success)
        {
            [subContext reset];
        }
    }
}

#pragma mark - adding the data to the store
- (void)addResult:(Results *)result store:(NSPersistentStore *)store context:(NSManagedObjectContext *)context
{
    NSEntityDescription *entity = [result entity];
    Results *copiedResult = [[Results alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
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
    [context assignObject:copiedResult toPersistentStore:store];
}

- (void)addHIVMed:(Medication *)med store:(NSPersistentStore *)store context:(NSManagedObjectContext *)context
{
    NSEntityDescription *entity = [med entity];
    Medication *copiedMed = [[Medication alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
    copiedMed.UID = med.UID;
    copiedMed.StartDate = med.StartDate;
    copiedMed.Name = med.Name;
    copiedMed.Dose = med.Dose;
    copiedMed.Drug = med.Drug;
    copiedMed.MedicationForm = med.MedicationForm;
    [context assignObject:copiedMed toPersistentStore:store];
}

- (void)addPreviousMed:(PreviousMedication *)med store:(NSPersistentStore *)store context:(NSManagedObjectContext *)context
{
    NSEntityDescription *entity = [med entity];
    PreviousMedication *copiedMed = [[PreviousMedication alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
    copiedMed.uID = med.uID;
    copiedMed.startDate = med.startDate;
    copiedMed.endDate = med.endDate;
    copiedMed.name = med.name;
    copiedMed.drug = med.drug;
    copiedMed.isART = med.isART;
    copiedMed.reasonEnded = med.reasonEnded;
    [context assignObject:copiedMed toPersistentStore:store];
}

- (void)addOtherMed:(OtherMedication *)med store:(NSPersistentStore *)store context:(NSManagedObjectContext *)context
{
    NSEntityDescription *entity = [med entity];
    OtherMedication *copiedMed = [[OtherMedication alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
    copiedMed.UID = med.UID;
    copiedMed.Unit = med.Unit;
    copiedMed.StartDate = med.StartDate;
    copiedMed.EndDate = med.EndDate;
    copiedMed.Name = med.Name;
    copiedMed.Dose = med.Dose;
    copiedMed.MedicationForm = med.MedicationForm;
    copiedMed.Image = med.Image;
    [context assignObject:copiedMed toPersistentStore:store];
}

- (void)addMissedMed:(MissedMedication *)med store:(NSPersistentStore *)store context:(NSManagedObjectContext *)context
{
    NSEntityDescription *entity = [med entity];
    MissedMedication *copiedMed = [[MissedMedication alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
    copiedMed.UID = med.UID;
    copiedMed.missedReason = med.missedReason;
    copiedMed.MissedDate = med.MissedDate;
    copiedMed.Name = med.Name;
    copiedMed.Drug = med.Drug;
    [context assignObject:copiedMed toPersistentStore:store];
}
- (void)addSideEffect:(SideEffects *)effect store:(NSPersistentStore *)store context:(NSManagedObjectContext *)context
{
    NSEntityDescription *entity = [effect entity];
    SideEffects *copiedEffect = [[SideEffects alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
    copiedEffect.UID = effect.UID;
    copiedEffect.SideEffect = effect.SideEffect;
    copiedEffect.SideEffectDate = effect.SideEffectDate;
    copiedEffect.seriousness = effect.seriousness;
    copiedEffect.Name = effect.Name;
    copiedEffect.Drug = effect.Drug;
    [context assignObject:copiedEffect toPersistentStore:store];
}

- (void)addContact:(Contacts *)contact store:(NSPersistentStore *)store context:(NSManagedObjectContext *)context
{
    NSEntityDescription *entity = [contact entity];
    Contacts *copiedContact = [[Contacts alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
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
    [context assignObject:copiedContact toPersistentStore:store];
}

- (void)addProcedure:(Procedures *)procedure store:(NSPersistentStore *)store context:(NSManagedObjectContext *)context
{
    NSEntityDescription *entity = [procedure entity];
    Procedures *copiedProcedure = [[Procedures alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
    copiedProcedure.UID = procedure.UID;
    copiedProcedure.Date = procedure.Date;
    copiedProcedure.Illness = procedure.Illness;
    copiedProcedure.Name = procedure.Name;
    copiedProcedure.Notes = procedure.Notes;
    copiedProcedure.EndDate = procedure.EndDate;
    copiedProcedure.CausedBy = procedure.CausedBy;
    [context assignObject:copiedProcedure toPersistentStore:store];
}

- (void)addWellness:(Wellness *)wellness store:(NSPersistentStore *)store context:(NSManagedObjectContext *)context
{
    NSEntityDescription *entity = [wellness entity];
    Wellness *copiedWellness = [[Wellness alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
    copiedWellness.uID = wellness.uID;
    copiedWellness.sleepBarometer = wellness.sleepBarometer;
    copiedWellness.moodBarometer = wellness.moodBarometer;
    copiedWellness.wellnessBarometer = wellness.wellnessBarometer;
    [context assignObject:copiedWellness toPersistentStore:store];
}


@end
