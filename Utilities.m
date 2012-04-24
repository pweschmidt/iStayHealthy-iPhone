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

+ (NSString *)GUID{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return [(NSString *)string autorelease];    
}

+ (BOOL)hasFloatingPoint:(NSNumber *)number{
    float fValue = [number floatValue];
    if (fmod(fValue, 1)) {
        return NO;
    }
    return YES;
}

+ (UIImage *)bannerImageFromLocale{
    NSLocale *locale = [NSLocale currentLocale];
    NSString *currentLocaleID = [locale localeIdentifier]; 
    
    if ([currentLocaleID hasPrefix:@"en"]) {
        if ([currentLocaleID isEqualToString:@"en_US"]
            ||[currentLocaleID isEqualToString:@"en_CA"]) {
            return [UIImage imageNamed:@"pozbannerEmpty.png"];
        }
        else {
            return [UIImage imageNamed:@"gaydarbanner.png"];
        }
    }
    else if ([currentLocaleID hasPrefix:@"de"]) {
        return [UIImage imageNamed:@"dahbanner.png"];
    }
    else if ([currentLocaleID hasPrefix:@"fr"]) {
        if ([currentLocaleID isEqualToString:@"fr_CA"]) {
            return [UIImage imageNamed:@"pozbannerEmpty.png"];
        }
        else {
            return [UIImage imageNamed:@"gaydarbanner.png"];
        }
    }
    else if ([currentLocaleID hasPrefix:@"es"]) {
        if ([currentLocaleID isEqualToString:@"es_ES"]) {
            return [UIImage imageNamed:@"gaydarbanner.png"];
        }
        else {
            return [UIImage imageNamed:@"pozbannerES.png"];
        }
    }
    //main EUROZONE get the gaydar banner
    else if([currentLocaleID hasPrefix:@"nl"] || [currentLocaleID hasPrefix:@"da"] || [currentLocaleID hasPrefix:@"it"] || [currentLocaleID hasPrefix:@"no"] || [currentLocaleID hasPrefix:@"sv"] ||
            [currentLocaleID isEqualToString:@"pt_PT"] || [currentLocaleID hasPrefix:@"fi"]){
        return [UIImage imageNamed:@"gaydarbanner.png"];
    }
    else {
        return [UIImage imageNamed:@"pozbannerEmpty.png"];
    }
    
}


@end
