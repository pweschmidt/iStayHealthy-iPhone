//
//  CoreDataManager.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/08/2013.
//
//

#import <Foundation/Foundation.h>

@interface CoreDataManager : NSObject
@property (nonatomic, strong) NSManagedObjectContext * defaultContext;
@property (nonatomic, assign) BOOL iCloudIsAvailable;

+(CoreDataManager *)sharedInstance;

- (void)setUpCoreDataManager;

- (void)saveContextAndWait:(NSError **)error;

- (void)saveContext:(NSError **)error;

- (NSURL *)applicationDocumentsDirectory;

- (void)importFileFromURL:(NSURL *)fileURL error:(NSError **)error;

@end
