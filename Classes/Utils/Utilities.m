//
//  Utilities.m
//  iStayHealthy
//
//  Created by peterschmidt on 31/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Utilities.h"
#import <math.h>

@implementation Utilities

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+ (NSString *)GUID
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)string;    
}

+ (BOOL)hasFloatingPoint:(NSNumber *)number
{
    float fValue = [number floatValue];
    if (fmod(fValue, 1))
    {
        return NO;
    }
    return YES;
}

+ (UIImage *)bannerImageFromLocale
{
    NSLocale *locale = [NSLocale currentLocale];
    NSString *currentLocaleID = [locale localeIdentifier]; 
    
    if ([currentLocaleID hasPrefix:@"en"])
    {
        if ([currentLocaleID isEqualToString:@"en_US"]
            ||[currentLocaleID isEqualToString:@"en_CA"])
        {
            return [UIImage imageNamed:@"pozbannerEmpty.png"];
        }
        else
        {
            return [UIImage imageNamed:@"gaydarbanner.png"];
        }
    }
    else if ([currentLocaleID hasPrefix:@"de"])
    {
        return [UIImage imageNamed:@"dahbanner.png"];
    }
    else if ([currentLocaleID hasPrefix:@"fr"])
    {
        if ([currentLocaleID isEqualToString:@"fr_CA"])
        {
            return [UIImage imageNamed:@"pozbannerEmpty.png"];
        }
        else
        {
            return [UIImage imageNamed:@"gaydarbanner.png"];
        }
    }
    else if ([currentLocaleID hasPrefix:@"es"])
    {
        if ([currentLocaleID isEqualToString:@"es_ES"])
        {
            return [UIImage imageNamed:@"gaydarbanner.png"];
        }
        else
        {
            return [UIImage imageNamed:@"pozbannerES.png"];
        }
    }
    //main EUROZONE get the gaydar banner
    else if([currentLocaleID hasPrefix:@"nl"] || [currentLocaleID hasPrefix:@"da"] || [currentLocaleID hasPrefix:@"it"] || [currentLocaleID hasPrefix:@"no"] || [currentLocaleID hasPrefix:@"sv"] ||
            [currentLocaleID isEqualToString:@"pt_PT"] || [currentLocaleID hasPrefix:@"fi"])
    {
        return [UIImage imageNamed:@"gaydarbanner.png"];
    }
    else
    {
        return [UIImage imageNamed:@"pozbannerEmpty.png"];
    }
    
}

+ (NSString *)urlStringFromLocale
{
    NSLocale *locale = [NSLocale currentLocale];
    NSString *currentLocaleID = [locale localeIdentifier]; 
    
    if ([currentLocaleID hasPrefix:@"en"]) {
        if ([currentLocaleID isEqualToString:@"en_US"]
            ||[currentLocaleID isEqualToString:@"en_CA"])
        {
            return @"http://www.poz.com";
        }
        else
        {
            return @"http://app.gaydar.net";
        }
    }
    else if ([currentLocaleID hasPrefix:@"de"])
    {
        return @"http://www.aidshilfe.de";
    }
    else if ([currentLocaleID hasPrefix:@"fr"])
    {
        if ([currentLocaleID isEqualToString:@"fr_CA"])
        {
            return @"http://www.poz.com";
        }
        else
        {
            return @"http://app.gaydar.net";
        }
    }
    else if ([currentLocaleID hasPrefix:@"es"])
    {
        if ([currentLocaleID isEqualToString:@"es_ES"])
        {
            return @"http://app.gaydar.net";
        }
        else
        {
            return @"http://www.poz.com/latino";
        }
    }
    //main EUROZONE get the gaydar banner
    else if([currentLocaleID hasPrefix:@"nl"] || [currentLocaleID hasPrefix:@"da"] || [currentLocaleID hasPrefix:@"it"] || [currentLocaleID hasPrefix:@"no"] || [currentLocaleID hasPrefix:@"sv"] ||
            [currentLocaleID isEqualToString:@"pt_PT"] || [currentLocaleID hasPrefix:@"fi"])
    {
        return @"http://app.gaydar.net";
    }
    else
    {
        return @"http://www.poz.com";
    }    
}

+ (NSString *)titleFromLocale
{
    NSLocale *locale = [NSLocale currentLocale];
    NSString *currentLocaleID = [locale localeIdentifier]; 
    
    if ([currentLocaleID hasPrefix:@"en"])
    {
        if ([currentLocaleID isEqualToString:@"en_US"]
            ||[currentLocaleID isEqualToString:@"en_CA"])
        {
            return @"POZ Magazine";
        }
        else
        {
            return @"Gaydar.net";
        }
    }
    else if ([currentLocaleID hasPrefix:@"de"])
    {
        return @"Deutsche AIDS Hilfe";
    }
    else if ([currentLocaleID hasPrefix:@"fr"])
    {
        if ([currentLocaleID isEqualToString:@"fr_CA"])
        {
            return @"POZ Magazine";
        }
        else
        {
            return @"Gaydar.net";
        }
    }
    else if ([currentLocaleID hasPrefix:@"es"])
    {
        if ([currentLocaleID isEqualToString:@"es_ES"])
        {
            return @"Gaydar.net";
        }
        else
        {
            return @"POZ Magazine ES";
        }
    }
    //main EUROZONE get the gaydar banner
    else if([currentLocaleID hasPrefix:@"nl"] || [currentLocaleID hasPrefix:@"da"] || [currentLocaleID hasPrefix:@"it"] || [currentLocaleID hasPrefix:@"no"] || [currentLocaleID hasPrefix:@"sv"] ||
            [currentLocaleID isEqualToString:@"pt_PT"] || [currentLocaleID hasPrefix:@"fi"])
    {
        return @"Gaydar.net";
    }
    else
    {
        return @"POZ Magazine";
    }        
}



@end
