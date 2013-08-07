//
//  CoreDataManageriOS6.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/08/2013.
//
//

#import "CoreDataManageriOS6.h"
#import "CoreDataConstants.h"

@interface CoreDataManageriOS6 ()
{
    NSManagedObjectContext * privateContext;
    dispatch_queue_t storeQueue;
}
@end

@implementation CoreDataManageriOS6
- (void)setUpCoreDataManager
{
    NSMergePolicy *policy = [[NSMergePolicy alloc]
                             initWithMergeType:NSMergeByPropertyObjectTrumpMergePolicyType];
    
    NSURL *modelURL = [[NSBundle mainBundle]
                       URLForResource:@"iStayHealthy"
                       withExtension:@"momd"];
    
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc]
                                   initWithContentsOfURL:modelURL];
    
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc]
                                         initWithManagedObjectModel:model];
    
    
    NSUInteger type = NSPrivateQueueConcurrencyType;
    privateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:type];
    [privateContext setPersistentStoreCoordinator:psc];
    [privateContext setMergePolicy:policy];
    
    type = NSMainQueueConcurrencyType;
    NSManagedObjectContext *mainContext = [[NSManagedObjectContext alloc]
                                           initWithConcurrencyType:type];
    
    [mainContext setParentContext:privateContext];
    [self setDefaultContext:mainContext];
    self.iCloudIsAvailable = ( nil != [[NSFileManager defaultManager] ubiquityIdentityToken]);
    storeQueue = dispatch_queue_create(kBackgroundQueueName, NULL);
}

- (void)saveContextAndWait:(NSError **)error
{
    [self saveContext:YES error:error];
}

- (void)saveContext:(NSError **)error
{
    [self saveContext:NO error:error];
}

- (void)importFileFromURL:(NSURL *)fileURL
                    error:(NSError **)error
{
}


- (void)saveContext:(BOOL)wait error:(NSError **)error
{
    NSManagedObjectContext *context = self.defaultContext;
    if (nil == context)
    {
        return;
    }
    if ([context hasChanges])
    {
        [context performBlockAndWait:^{
            [context save:error];
        }];
    }
    
    void (^savePrivateContext) (void) = ^{[privateContext save:error];};
    
    if ([privateContext hasChanges])
    {
        if (wait)
        {
            [privateContext performBlockAndWait:savePrivateContext];
        }
        else
        {
            [privateContext performBlock:savePrivateContext];
        }
    }
    
}

@end
