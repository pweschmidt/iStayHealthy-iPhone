//
//  CoreDataManager.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/08/2013.
//
//

#import "CoreDataManager.h"
#import "CoreDataManagerPlaceholder.h"
#import "CoreDataUtils.h"
#import "CoreDataConstants.h"
#import "CoreXMLReader.h"

@implementation CoreDataManager
+(CoreDataManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    static CoreDataManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

+ (id)alloc
{
    if (self == [CoreDataManager self])
    {
        return [[CoreDataManagerPlaceholder alloc] init];
    }
    else
    {
        return [super alloc];
    }
}

- (void)setUpCoreDataManager
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass of %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])]
                                 userInfo:nil];
}

- (void)setUpStoreWithError:(iStayHealthyErrorBlock)error
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass of %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])]
                                 userInfo:nil];    
}


- (void)saveContextAndWait:(NSError **)error
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass of %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])]
                                 userInfo:nil];
    
}
- (void)saveContext:(NSError **)error
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass of %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])]
                                 userInfo:nil];
    
}

- (void)fetchDataForEntityName:(NSString *)entityName
                     predicate:(NSPredicate *)predicate
                      sortTerm:(NSString *)sortTerm
                     ascending:(BOOL)ascending
                    completion:(iStayHealthyArrayCompletionBlock)completion
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass of %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])]
                                 userInfo:nil];    
}





#pragma mark - implemented methods

- (id)managedObjectForEntityName:(NSString *)entityName
{
    return [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.defaultContext];
}


- (void)addFileToImportList:(NSURL *)sourceURL error:(NSError **)error
{
    if (nil == sourceURL)
    {
        return;
    }
    NSString *dstPath = [NSString stringWithFormat:@"%@/%@",NSTemporaryDirectory(), [sourceURL lastPathComponent]];
    NSString *sourcePath = [sourceURL absoluteString];
    [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:dstPath error:error];
    if (nil == error && [[NSFileManager defaultManager] fileExistsAtPath:dstPath])
    {
        NSData *xmlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:dstPath]];
        NSDictionary * importData = @{kImportedDataFromFileKey : xmlData,
                                      kTmpFileKey : dstPath};
        self.hasDataForImport = YES;
        NSNotification * notification = [NSNotification
                                         notificationWithName:kImportedDataAvailableKey
                                         object:self
                                         userInfo:importData];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}


- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager]
             URLsForDirectory:NSDocumentDirectory
             inDomains:NSUserDomainMask] lastObject];
}

- (void)iCloudStoreChanged:(NSNotification *)notification
{
    id currentToken = [[NSFileManager defaultManager] ubiquityIdentityToken];
    id formerToken = [CoreDataUtils ubiquityTokenFromArchive];
    if (![formerToken isEqual:currentToken])
    {
        [CoreDataUtils dropUbiquityToken];
        [CoreDataUtils archiveUbiquityToken:currentToken];
    }
}

- (void)importWhenReady:(NSNotification *)notification
{
    if (nil == notification)
    {
        return;
    }
    NSString * tmpFilePath = [notification.userInfo objectForKey:kTmpFileKey];
    NSData *xmlData = [notification.userInfo objectForKey:kImportedDataAvailableKey];
    self.hasDataForImport = YES;
    self.xmlTmpPath = tmpFilePath;
    self.xmlImportData = xmlData;
    if (self.storeIsReady)
    {
        [self importWithData];
    }
}

- (void)importWithData
{
    if (nil == self.xmlImportData || nil == self.xmlTmpPath)
    {
        return;
    }
    [[CoreXMLReader sharedInstance] parseXMLData:self.xmlImportData];
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.xmlTmpPath])
    {
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:self.xmlTmpPath error:&error];
    }
    self.hasDataForImport = NO;
    self.xmlTmpPath = nil;
    self.xmlImportData = nil;
}


@end
