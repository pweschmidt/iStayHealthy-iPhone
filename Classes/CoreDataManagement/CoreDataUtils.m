//
//  CoreDataUtils.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/08/2013.
//
//

#import "CoreDataUtils.h"
#import "CoreDataConstants.h"

@implementation CoreDataUtils
+ (NSDictionary *)localStoreOptions
{
    return [NSDictionary
            dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],
            NSMigratePersistentStoresAutomaticallyOption,
            [NSNumber numberWithBool:YES],
            NSInferMappingModelAutomaticallyOption, nil];
}

+ (NSDictionary *)iCloudStoreOptions
{
//	NSFileManager *fileManager = [[NSFileManager alloc] init];
//	NSURL *ubiquityContainer = [fileManager URLForUbiquityContainerIdentifier:kICloudTeamID];
//	if (nil == ubiquityContainer)
//	{
//		return nil;
//	}
//	NSString *coreDataCloudContent = [[ubiquityContainer path]
//	                                  stringByAppendingPathComponent:@"data"];
//	NSURL *amendedCloudURL = [NSURL fileURLWithPath:coreDataCloudContent];
    return [NSDictionary
            dictionaryWithObjectsAndKeys:
            [NSNumber numberWithBool:YES],
            NSMigratePersistentStoresAutomaticallyOption,
            [NSNumber numberWithBool:YES],
            NSInferMappingModelAutomaticallyOption,
            kUbiquitousPath,
            NSPersistentStoreUbiquitousContentNameKey/*,
                                                        amendedCloudURL,
                                                        NSPersistentStoreUbiquitousContentURLKey*/, nil];
}

+ (NSDictionary *)noiCloudStoreOptions
{
	return [NSDictionary
	        dictionaryWithObjectsAndKeys:
	        [NSNumber numberWithBool:YES],
	        NSMigratePersistentStoresAutomaticallyOption,
	        [NSNumber numberWithBool:YES],
	        NSInferMappingModelAutomaticallyOption,
	        kUbiquitousPath,
	        NSPersistentStoreUbiquitousContentNameKey,
	        [NSNumber numberWithBool:@(YES)],
	        NSPersistentStoreRemoveUbiquitousMetadataOption, nil];
}

+ (NSDictionary *)newiCloudStoreOptions
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSURL *ubiquityContainer = [fileManager URLForUbiquityContainerIdentifier:kICloudTeamID];

    if (nil == ubiquityContainer)
    {
        return nil;
    }
    NSString *coreDataCloudContent = [[ubiquityContainer path]
                                      stringByAppendingPathComponent:@"data"];
    NSURL *amendedCloudURL = [NSURL fileURLWithPath:coreDataCloudContent];
    return [NSDictionary
            dictionaryWithObjectsAndKeys:
            [NSNumber numberWithBool:YES],
            NSMigratePersistentStoresAutomaticallyOption,
            [NSNumber numberWithBool:YES],
            NSInferMappingModelAutomaticallyOption,
            kNewUbiquitousPath,
            NSPersistentStoreUbiquitousContentNameKey,
            amendedCloudURL,
            NSPersistentStoreUbiquitousContentURLKey, nil];
}

+ (void)archiveUbiquityToken:(id)token
{
    if (nil == token)
    {
        [CoreDataUtils dropUbiquityToken];
        return;
    }
    NSData *currentTokenData = [NSKeyedArchiver archivedDataWithRootObject:token];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:currentTokenData forKey:kUbiquityTokenKey];
    [defaults synchronize];
}

+ (id)ubiquityTokenFromArchive
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *formerTokenData = [defaults objectForKey:kUbiquityTokenKey];

    return [NSKeyedUnarchiver unarchiveObjectWithData:formerTokenData];
}

+ (void)dropUbiquityToken
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUbiquityTokenKey];
}

@end
