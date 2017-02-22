//
//  AppSettings.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 02/08/2014.
//
//

#import "AppSettings.h"
#import "KeychainHandler.h"
#import "CoreDataConstants.h"

@implementation AppSettings
+ (AppSettings *)sharedInstance
{
	static dispatch_once_t onceToken;
	static AppSettings *handling = nil;
	dispatch_once(&onceToken, ^{
	    handling = [AppSettings new];
	});
	return handling;
}

//- (void)disablePasswordForUpdate
//{
//	if (![self hasUpdated] && [self hasPasswordEnabled])
//	{
//		[KeychainHandler resetPasswordAndFlags];
//		BOOL hasPassword = [self hasPasswordEnabled];
//		if (hasPassword) // make damn sure
//		{
//			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//			[defaults setBool:NO forKey:kIsPasswordEnabled];
//			[defaults synchronize];
//		}
//	}
//}

//- (BOOL)hasUpdated
//{
//	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//	BOOL hasUpdatedToCurrentVersion = [defaults boolForKey:kIsVersionUpdate401];
//	return hasUpdatedToCurrentVersion;
//}
//
//- (void)resetUpdateSettings
//{
//	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//	[defaults setBool:YES forKey:kIsVersionUpdate401];
//	[defaults synchronize];
//}

- (BOOL)hasPasswordEnabled
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	BOOL isPasswordEnabled = [defaults boolForKey:kIsPasswordEnabled];
	return isPasswordEnabled;
}


//- (NSString *)updateMessage
//{
//	if (![self hasUpdated])
//	{
//		NSMutableString *helpString = [NSMutableString string];
//		if ([self hasPasswordEnabled])
//		{
//			NSString *passReset = NSLocalizedString(@"Please reset password after upgrade", nil);
//			[helpString appendString:passReset];
//		}
//		NSString *iCloud = NSLocalizedString(@"iCloudLoading", nil);
//		[helpString appendString:@" "];
//		[helpString appendString:iCloud];
//		NSString *data = NSLocalizedString(@"DataVisibility", nil);
//		[helpString appendString:@" "];
//		[helpString appendString:data];
//		return helpString;
//	}
//	else
//	{
//		return nil;
//	}
//}

- (void)saveUbiquityURL:(NSURL *)ubiquityURL
{
	if (nil != ubiquityURL && [ubiquityURL isKindOfClass:[NSURL class]])
	{
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSString *path = [ubiquityURL path];
		[defaults setObject:path forKey:kStoreUbiquityPathKey];
		[defaults synchronize];
	}
}

- (NSString *)ubiquityContentName
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *ubiquityURL = [defaults objectForKey:kStoreUbiquityPathKey];
	if (nil != ubiquityURL)
	{
//		NSString *string = [self cleanedContentNameFromFullPathString:ubiquityURL];
	}

	return kUbiquitousPath;
}

- (NSString *)cleanedContentNameFromFullPathString:(NSString *)pathString
{
	NSString *path = kUbiquitousPath;
	if (nil == pathString)
	{
		return path;
	}


	NSArray *storeComponents = [pathString componentsSeparatedByString:@"/"];
	[storeComponents enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        
#ifdef APPDEBUG
	    NSLog(@"Path component %@", obj);
#endif
	}];

	return path;
}

- (NSString *)versionString
{
	NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	return version;
}

- (NSString *)buildNumberString
{
	NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
	return version;
}

@end
