//
//  CoreDataManager.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/08/2013.
//
//

#import "CoreDataManager.h"
#import "CoreDataManagerPlaceholder.h"


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

- (void)importFileFromURL:(NSURL *)fileURL
                    error:(NSError **)error
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass of %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])]
                                 userInfo:nil];
}


#pragma mark - implemented methods

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager]
             URLsForDirectory:NSDocumentDirectory
             inDomains:NSUserDomainMask] lastObject];
}



@end
