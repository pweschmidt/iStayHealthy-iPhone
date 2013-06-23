//
//  DatabaseController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 23/06/2013.
//
//

#import "DatabaseController.h"
#import "Constants.h"

static NSMergePolicyType kiStayHealthyMergePolicy = NSMergeByPropertyObjectTrumpMergePolicyType;


@interface DatabaseController ()
@property (strong) NSManagedObjectContext *rootContext;
@property (nonatomic, strong) NSURL * mainStore;
@property (nonatomic, strong) NSURL * backupStore;
@end

@implementation DatabaseController

+ (id)sharedInstance
{
    static DatabaseController * sharedController = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        sharedController = [[DatabaseController alloc] init];
    });
    return sharedController;
}

- (id)init
{
    self = [super init];
    if (nil != self) {
        _rootContext = nil;
        _mainStore = nil;
        _backupStore = nil;
    }
    return self;
}

- (void)setUpCoreDataStack
{
    NSMergePolicy *policy = [[NSMergePolicy alloc] initWithMergeType:kiStayHealthyMergePolicy];
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"iStayHealthy" withExtension:@"momd"];
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSPersistentStoreCoordinator *coordinator = nil;
    coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
    NSManagedObjectContext *context = nil;
    context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [context setPersistentStoreCoordinator:coordinator];
    [context setMergePolicy:policy];
    
    NSManagedObjectContext *mainContext = nil;
    mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [mainContext setParentContext:context];
    
    _rootContext = context;
}


#pragma Core Data Stack options 

- (NSDictionary *)iCloudOptionsForUbiquityContainerURL:(NSURL *)ubiquityContainerURL
{
    NSNumber *yes = [NSNumber numberWithBool:YES];
    return @{NSMigratePersistentStoresAutomaticallyOption : yes,
             NSInferMappingModelAutomaticallyOption : yes,
             NSPersistentStoreUbiquitousContentNameKey : kUbiquitousKeyPath,
             NSPersistentStoreUbiquitousContentURLKey : ubiquityContainerURL};
}

- (NSDictionary *)standardCoreDataOptions
{
    NSNumber *yes = [NSNumber numberWithBool:YES];
    return @{NSMigratePersistentStoresAutomaticallyOption : yes,
             NSInferMappingModelAutomaticallyOption : yes};
}

- (NSDictionary *)readOnlyOptions
{
    return @{ NSReadOnlyPersistentStoreOption : [NSNumber numberWithBool:YES] };
}

@end
