//
//  Utilities.m
//  iStayHealthy
//
//  Created by peterschmidt on 31/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Utilities.h"
#import "NSDate+Extras.h"
#import <math.h>
#import <QuartzCore/QuartzCore.h>

static NSDictionary * medNameMap()
{
    NSDictionary *map = @{ @"trii" : @"triumeq",
                           @"sunvepra" : @"FDA",
                           @"elvitegravir" : @"vitekta",
                           @"cobicistat" : @"tybost",
                           @"dalkinza" : @"FDA" };

    return map;
}

@implementation Utilities

+ (CGRect)frameFromSize:(CGSize)size
{
    return CGRectMake(size.width / 2 - 70, size.height / 2 - 70, 140, 140);
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
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    label.font = [UIFont boldSystemFontOfSize:12];
    [activityIndicator addSubview:label];
    return activityIndicator;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        // Initialization code here.
    }

    return self;
}

+ (NSString *)GUID
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);

    CFRelease(theUUID);
    NSString *guidString = (__bridge NSString *) string;
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
    else if ([currentLocaleID hasPrefix:@"es"])
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
    else if ([currentLocaleID hasPrefix:@"es"])
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
    else if ([currentLocaleID hasPrefix:@"es"])
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
    else if ([currentLocaleID hasPrefix:@"es"])
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

+ (NSDictionary *)calendarDictionary
{
    NSArray *months = @[NSLocalizedString(@"January", nil),
                        NSLocalizedString(@"February", nil),
                        NSLocalizedString(@"March", nil),
                        NSLocalizedString(@"April", nil),
                        NSLocalizedString(@"May", nil),
                        NSLocalizedString(@"June", nil),
                        NSLocalizedString(@"July", nil),
                        NSLocalizedString(@"August", nil),
                        NSLocalizedString(@"September", nil),
                        NSLocalizedString(@"October", nil),
                        NSLocalizedString(@"November", nil),
                        NSLocalizedString(@"December", nil)];

    NSArray *shortDays = @[NSLocalizedString(@"S", @"Sunday"),
                           NSLocalizedString(@"M", @"Monday"),
                           NSLocalizedString(@"T", @"Tuesday"),
                           NSLocalizedString(@"W", @"Wednesday"),
                           NSLocalizedString(@"T", @"Thursday"),
                           NSLocalizedString(@"F", @"Friday"),
                           NSLocalizedString(@"S", @"Saturday")];

    NSDictionary *dictionary = @{ @"months": months,
                                  @"shortDays" : shortDays };

    return dictionary;
}

+ (NSDateComponents *)dateComponentsForDate:(NSDate *)date
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];

    return [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitWeekOfMonth
                       fromDate:date];
}

+ (NSString *)monthForDate:(NSDate *)date
{
    NSDateComponents *components = [[self class] dateComponentsForDate:date];
    NSArray *months = [[[self class] calendarDictionary] objectForKey:@"months"];
    int monthIndex = (int) (components.month - 1);

    return (NSString *) [months objectAtIndex:monthIndex];
}

+ (NSString *)weekDayForDate:(NSDate *)date
{
    NSDateComponents *components = [[self class] dateComponentsForDate:date];
    NSArray *weekdays = [[[self class] calendarDictionary] objectForKey:@"shortDays"];
    int dayIndex = (int) (components.weekday - 1);

    return (NSString *) [weekdays objectAtIndex:dayIndex];
}

+ (NSInteger)daysInMonth:(NSInteger)month inYear:(NSInteger)inYear
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];

    if (1 > month)
    {
        month = 1;
    }
    else if (12 < month)
    {
        month = 12;
    }
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:1];
    [components setMonth:month];
    [components setYear:inYear];

    NSDate *date = [calendar dateFromComponents:components];
    NSRange days = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    return days.length;
}

+ (NSUInteger)monthsToMonitorFromStartDate:(NSDate *)startDate endDate:(NSDate *)endDate
{
    NSDateComponents *startComponents = [[self class] dateComponentsForDate:startDate];
    NSDateComponents *endComponents = [[self class] dateComponentsForDate:endDate];
    NSUInteger startMonth = startComponents.month;
    NSUInteger endMonth = endComponents.month;
    NSUInteger result = 0;

    if (endMonth < startMonth)
    {
        result = 12 - startMonth + endMonth;
    }
    else
    {
        result = endMonth - startMonth + 1;
    }
    return result;
}

+ (NSUInteger)weeksInMonthForDate:(NSDate *)date isStartDate:(BOOL)isStartDate
{
    NSDateComponents *components = [[self class] dateComponentsForDate:date];
    NSUInteger weeks = components.weekOfMonth - 1;     // needs to be 0 based

    if (isStartDate)
    {
        NSUInteger days = [date daysInMonth] - components.day + 1;         // including the start day
        NSInteger weekday = components.weekday - 1;         // start Monday not Sunday
        if (7 >= days)
        {
            weeks = (7 < weekday + days) ? 2 : 1;
        }
        else
        {
            weeks = days / 7;
            if (1 < weekday)
            {
                weeks++;
            }
        }
    }
    return weeks;
}

+ (NSDateComponents *)fullComponentsFromDay:(NSInteger)day month:(NSInteger)month year:(NSInteger)year
{
    NSDate *date = [NSDate dateFromDay:day month:month year:year];

    return [[self class] dateComponentsForDate:date];
}

+ (BOOL)isIPad
{
    static dispatch_once_t token;
    static BOOL isiPadIdiom = NO;

    dispatch_once(&token, ^{
                      isiPadIdiom = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad;
                  });
    return isiPadIdiom;
}

+ (BOOL)isSimulator
{
    static dispatch_once_t token;
    static BOOL isSimulator = NO;

    dispatch_once(&token, ^{
                      NSString *model = [UIDevice currentDevice].model;
                      model = [model lowercaseString];
                      isSimulator = ([model rangeOfString:@"simulator"].location != NSNotFound);
                  });

    return isSimulator;
}

+ (NSString *)imageNameFromMedName:(NSString *)medName
{
    NSArray *stringArray = [medName componentsSeparatedByString:@"/"];
    NSString *imageName = [(NSString *) [stringArray objectAtIndex:0] lowercaseString];
    NSArray *finalArray = [imageName componentsSeparatedByString:@" "];

    NSString *revisedImageName = (NSString *) [[finalArray objectAtIndex:0] lowercaseString];
    NSString *foundMappedName = [medNameMap() objectForKey:revisedImageName];

    if (nil != foundMappedName)
    {
        revisedImageName = foundMappedName;
    }

    return revisedImageName;
}

+ (UIImage *)imageFromMedName:(NSString *)medName
{
    if (nil == medName)
    {
        return nil;
    }
    NSString *imageName = [[self class] imageNameFromMedName:medName];
    NSString *pillPath = [[NSBundle mainBundle]
                          pathForResource:[imageName lowercaseString] ofType:@"png"];
    return [UIImage imageWithContentsOfFile:pillPath];
}

+ (NSDictionary *)resultsTypeDictionary
{
    static dispatch_once_t onceToken;
    static NSDictionary *dictionary = nil;

    dispatch_once(&onceToken, ^{
                      dictionary = @{
                          kCD4 : NSLocalizedString(kCD4, nil),
                          kViralLoad : NSLocalizedString(kViralLoad, nil),
                          kCD4Percent : NSLocalizedString(kCD4Percent, nil),
                          kHepCViralLoad : NSLocalizedString(kHepCViralLoad, nil),
                          kGlucose : NSLocalizedString(kGlucose, nil),
                          kTotalCholesterol : NSLocalizedString(kTotalCholesterol, nil),
                          kLDL : NSLocalizedString(kLDL, nil),
                          kHDL : NSLocalizedString(kHDL, nil),
                          kTriglyceride : NSLocalizedString(kTriglyceride, nil),
                          kHeartRate : NSLocalizedString(kHeartRate, nil),
                          kSystole : NSLocalizedString(kSystole, nil),
                          kDiastole : NSLocalizedString(kDiastole, nil),
                          kBloodPressure : NSLocalizedString(kBloodPressure, nil),
                          kOxygenLevel : NSLocalizedString(kOxygenLevel, nil),
                          kWeight : NSLocalizedString(kWeight, nil),
                          kBMI : NSLocalizedString(kBMI, nil),
                          kHemoglobulin : NSLocalizedString(kHemoglobulin, nil),
                          kPlatelet : NSLocalizedString(kPlatelet, nil),
                          kWhiteBloodCells : NSLocalizedString(kWhiteBloodCells, nil),
                          kRedBloodCells : NSLocalizedString(kRedBloodCells, nil),
                          kCholesterolRatio : NSLocalizedString(kCholesterolRatio, nil),
                          kCardiacRiskFactor : NSLocalizedString(kCardiacRiskFactor, nil),
                          kCholesterolRatio : NSLocalizedString(kCholesterolRatio, nil),
                          kLiverAlanineTransaminase : NSLocalizedString(kLiverAlanineTransaminase, nil),
                          kLiverAspartateTransaminase : NSLocalizedString(kLiverAspartateTransaminase, nil),
                          kLiverAlkalinePhosphatase : NSLocalizedString(kLiverAlkalinePhosphatase, nil),
                          kLiverAlbumin : NSLocalizedString(kLiverAlbumin, nil),
                          kLiverAlanineTotalBilirubin : NSLocalizedString(kLiverAlanineTotalBilirubin, nil),
                          kLiverAlanineDirectBilirubin : NSLocalizedString(kLiverAlanineDirectBilirubin, nil),
                          kLiverGammaGlutamylTranspeptidase : NSLocalizedString(kLiverGammaGlutamylTranspeptidase, nil)
                      };
                  });
    return dictionary;
}

+ (NSDictionary *)colourTypeDictionary
{
    static dispatch_once_t onceToken;
    static NSDictionary *colourDictionary = nil;

    dispatch_once(&onceToken, ^{
                      colourDictionary = @{
                          kCD4 : DARK_YELLOW,
                          kViralLoad : DARK_BLUE,
                          kCD4Percent : DARK_YELLOW,
                          kHepCViralLoad : DARK_RED,
                          kGlucose : DARK_RED,
                          kTotalCholesterol : DARK_RED,
                          kLDL : DARK_RED,
                          kHDL : DARK_RED,
                          kTriglyceride : DARK_RED,
                          kHeartRate : DARK_GREEN,
                          kSystole : DARK_GREEN,
                          kDiastole : DARK_GREEN,
                          kBloodPressure : DARK_GREEN,
                          kOxygenLevel : DARK_GREEN,
                          kWeight : DARK_GREEN,
                          kBMI : DARK_GREEN,
                          kHemoglobulin : DARK_RED,
                          kPlatelet : DARK_RED,
                          kWhiteBloodCells : DARK_RED,
                          kRedBloodCells : DARK_RED,
                          kCholesterolRatio : DARK_RED,
                          kCardiacRiskFactor : DARK_GREEN,
                          kCholesterolRatio : DARK_RED,
                          kLiverAlanineTransaminase : DARK_RED,
                          kLiverAspartateTransaminase : DARK_RED,
                          kLiverAlkalinePhosphatase : DARK_RED,
                          kLiverAlbumin : DARK_RED,
                          kLiverAlanineTotalBilirubin : DARK_RED,
                          kLiverAlanineDirectBilirubin : DARK_RED,
                          kLiverGammaGlutamylTranspeptidase : DARK_RED
                      };
                  });
    return colourDictionary;
}

+ (CGRect)popUpFrameInMainFrame:(CGRect)mainFrame
{
    if ([[self class] isIPad])
    {
        CGFloat height = 568;
        CGFloat width = 320;
        CGFloat xOffset = mainFrame.size.width / 2 - width / 2;
        CGFloat yOffset = mainFrame.size.height / 2 - height / 2;
        return CGRectMake(xOffset, yOffset, width, height);
    }
    return CGRectZero;
}

+ (UIModalPresentationStyle)modalPresentationStyle
{
    return UIModalPresentationFullScreen;
}


@end
