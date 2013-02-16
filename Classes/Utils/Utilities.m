//
//  Utilities.m
//  iStayHealthy
//
//  Created by peterschmidt on 31/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Utilities.h"
#import <math.h>
#import <QuartzCore/QuartzCore.h>

@implementation Utilities

+ (CGRect)frameFromSize:(CGSize)size
{
    return CGRectMake(size.width/2 - 70, size.height/2-70, 140, 140);
}


+ (UIActivityIndicatorView *)activityIndicatorViewWithFrame:(CGRect)frame
{
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    activityIndicator.frame = frame;
    activityIndicator.layer.cornerRadius = 10;
    CGRect labelFrame = CGRectMake(15, 90, 100, 30);
    UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
    label.text = NSLocalizedString(@"Loading", "Loading");
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = UITextAlignmentCenter;
    label.lineBreakMode = UILineBreakModeWordWrap;
    label.numberOfLines = 0;
    label.font = [UIFont boldSystemFontOfSize:12];
    [activityIndicator addSubview:label];
    return activityIndicator;
}


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
    NSString *guidString = (__bridge NSString *)string;
    CFRelease(string);
    return guidString;
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
    
    if ([currentLocaleID hasPrefix:@"de"])
    {
        return [UIImage imageNamed:@"dahbanner.png"];
    }
    else if ([currentLocaleID hasPrefix:@"es"])
    {
        return [UIImage imageNamed:@"pozbannerES.png"];
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
    
    if ([currentLocaleID hasPrefix:@"de"])
    {
        return @"http://www.aidshilfe.de";
    }
    else if ([currentLocaleID hasPrefix:@"es"])
    {
            return @"http://www.poz.com/latino";
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
    
    if ([currentLocaleID hasPrefix:@"de"])
    {
        return @"Deutsche AIDS Hilfe";
    }
    else if ([currentLocaleID hasPrefix:@"es"])
    {
        return @"POZ Magazine ES";
    }
    else
    {
        return @"POZ Magazine";
    }        
}



@end
