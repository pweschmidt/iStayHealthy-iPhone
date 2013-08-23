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
    label.textAlignment = NSTextAlignmentCenter;
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

+ (NSString *)medListURLFromLocale
{
    NSLocale *locale = [NSLocale currentLocale];
    NSString *currentLocaleID = [locale localeIdentifier];
    if ([currentLocaleID hasPrefix:@"de"])
    {
        return @"http://www.aidshilfe.de/de/leben-mit-hiv/medizinische-infos/medikamente";
    }
    else if([currentLocaleID hasPrefix:@"es"])
    {
        if ([currentLocaleID hasSuffix:@"ES"])
        {
            return @"http://www.aidsmap.com/v634746756360000000/file/1051858/ARV_drug_chart_Spanish.pdf";
        }
        else
        {
            return @"http://www.aidsmeds.com/list.shtml";            
        }
    }
    else if ([currentLocaleID hasPrefix:@"en"])
    {
        if ([currentLocaleID hasSuffix:@"GB"])
        {
            return @"http://i-base.info/guides/category/arvs";
        }
        else
        {
            return @"http://www.aidsmeds.com/list.shtml";
        }
    }
    else if ([currentLocaleID hasPrefix:@"fr"])
    {
        if ([currentLocaleID hasSuffix:@"CA"])
        {
            return @"http://www.catie.ca/fr/guides-pratiques/traitement-antiretroviral/annexes/b";
        }
        else
        {
            return @"http://www.aidsmap.com/v634746760450000000/file/1051857/ARV_drugchart_FRE_Dec2011_Web.pdf";
        }
    }
    else
    {
        return @"http://www.aidsmeds.com/list.shtml";        
    }
}

+ (NSString *)generalInfoURLFromLocale
{
    NSLocale *locale = [NSLocale currentLocale];
    NSString *currentLocaleID = [locale localeIdentifier];
    if ([currentLocaleID hasPrefix:@"de"])
    {
        return @"http://www.aidshilfe.de/de/adressen";
    }
    else if([currentLocaleID hasPrefix:@"es"])
    {
        if ([currentLocaleID hasSuffix:@"ES"])
        {
            return @"http://www.aidsmap.com/es";
        }
        else
        {
            return @"http://www.poz.com/latino";
        }
    }
    else if ([currentLocaleID hasPrefix:@"en"])
    {
        if ([currentLocaleID hasSuffix:@"GB"])
        {
            return @"http://www.aidsmap.com/hiv-basics";
        }
        else
        {
            return @"http://aids.gov/hiv-aids-basics/";
        }
    }
    else if ([currentLocaleID hasPrefix:@"fr"])
    {
        if ([currentLocaleID hasSuffix:@"CA"])
        {
            return @"http://www.catie.ca/fr/essentiel";
        }
        else
        {
            return @"http://www.aidsmap.com/translations/fr/Le-BAba-du-VIH-The-basics/page/1330873/";
        }
    }
    else
    {
        return @"http://www.aidsmeds.com/list.shtml";
    }
    
}

+ (NSString *)testingInfoURLFromLocale
{
    NSLocale *locale = [NSLocale currentLocale];
    NSString *currentLocaleID = [locale localeIdentifier];
    if ([currentLocaleID hasPrefix:@"de"])
    {
        return @"http://www.aidshilfe.de/de/sich-schuetzen/hiv/aids/hiv-test";
    }
    else if([currentLocaleID hasPrefix:@"es"])
    {
        if ([currentLocaleID hasSuffix:@"ES"])
        {
            return @"http://www.aidsmap.com/es";
        }
        else
        {
            return @"http://www.poz.com/latino";
        }
    }
    else if ([currentLocaleID hasPrefix:@"en"])
    {
        if ([currentLocaleID hasSuffix:@"GB"])
        {
            return @"http://www.aidsmap.com/hiv-basics/Testing/page/1412439";
        }
        else
        {
            return @"http://www.poz.com/hiv_testing.shtml";
        }
    }
    else if ([currentLocaleID hasPrefix:@"fr"])
    {
        if ([currentLocaleID hasSuffix:@"CA"])
        {
            return @"http://www.catie.ca/fr/prevention/depistage-diagnostic";
        }
        else
        {
            return @"http://www.aidsmap.com/translations/fr/Le-BAba-du-VIH-The-basics/page/1330873/";
        }
    }
    else
    {
        return @"http://www.aidsmeds.com/list.shtml";
    }
    
}

+ (NSString *)preventionURLFromLocale
{
    NSLocale *locale = [NSLocale currentLocale];
    NSString *currentLocaleID = [locale localeIdentifier];
    if ([currentLocaleID hasPrefix:@"de"])
    {
        return @"http://www.aidshilfe.de/de/sich-schuetzen/hiv/aids/safer-sex";
    }
    else if([currentLocaleID hasPrefix:@"es"])
    {
        if ([currentLocaleID hasSuffix:@"ES"])
        {
            return @"http://www.aidsmap.com/es";
        }
        else
        {
            return @"http://www.poz.com/latino";
        }
    }
    else if ([currentLocaleID hasPrefix:@"en"])
    {
        if ([currentLocaleID hasSuffix:@"GB"])
        {
            return @"http://www.aidsmap.com/hiv-basics/Transmission/page/1412438/";
        }
        else
        {
            return @"http://www.poz.com/archive/2008_Mar_2168.shtml";
        }
    }
    else if ([currentLocaleID hasPrefix:@"fr"])
    {
        if ([currentLocaleID hasSuffix:@"CA"])
        {
            return @"http://www.catie.ca/fr/prevention";
        }
        else
        {
            return @"http://www.aidsmap.com/translations/fr/Le-BAba-du-VIH-The-basics/page/1330873/";
        }
    }
    else
    {
        return @"http://www.aidsmeds.com/list.shtml";
    }
    
}

+ (BOOL)isIPad
{
    return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad;
}

@end
