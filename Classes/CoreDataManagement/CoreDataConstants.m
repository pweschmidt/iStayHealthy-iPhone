//
//  CoreDataConstants.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/08/2013.
//
//

#import "CoreDataConstants.h"
NSString * const kPersistentMainStore    = @"iStayHealthy.sqlite";
NSString * const kPersistentFallbackStore       = @"iStayHealthyBackup.sqlite";

NSString * const kUbiquitousPath                = @"5Y4HL833A4.com.pweschmidt.iStayHealthy.store";

NSString * const kICloudTeamID                  = @"5Y4HL833A4.com.pweschmidt.iStayHealthy";
NSString * const kLoadedStoreNotificationKey    = @"LoadedStore";
NSString * const kImportedDataFromFileKey       = @"ImportedData";
NSString * const kErrorStoreNotificationKey     = @"ErrorLoadingStore";
NSString * const kErrorImportFromFileKey        = @"ErrorImportingFile";
NSString * const kUbiquityTokenKey              = @"com.pweschmidt.iStayHealthy.ubiquityToken";
NSString * const kImportedDataAvailableKey      = @"ImportedDataAvailable";
NSString * const kTmpFileKey                    = @"TemporaryFile";

char * const kBackgroundQueueName               = "com.pweschmidt.iStayHealthy.background.queue";


