//
//  ResultsAnalysis.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 29/08/2012.
//
//

#import "ResultsAnalysis.h"
#import "Constants.h"
#import "Results.h"

@interface ResultsAnalysis ()
+ (NSNumber *)valueForType:(NSString *)value result:(Results *)result;
@end

@implementation ResultsAnalysis

- (id)initWithResults:(NSArray *)allResults
{
    self = [super init];
    if (nil != self)
    {
        if (nil == allResults)
        {
            self.results = [NSMutableArray array];
        }
        else
        {
            self.results = [NSMutableArray arrayWithArray:allResults];            
        }
    }
    return self;
}



- (NSDictionary *)resultsForValue:(NSString *)value
{
    NSMutableDictionary *resultsDict = [NSMutableDictionary dictionary];
    BOOL hasFoundFirst = NO;
    float firstFoundValue = 0;
    for (Results *result in self.results)
    {
        NSNumber *candidate = [ResultsAnalysis valueForType:value result:result];
        if (nil != candidate)
        {
            float fValue = [candidate floatValue];
            if (0 <= fValue)
            {
                if (!hasFoundFirst)
                {
                    firstFoundValue = fValue;
                    hasFoundFirst = YES;
                    [resultsDict setValue:candidate forKey:kLastValueKey];
                }
                else
                {
                    [resultsDict setValue:candidate forKey:kPreviousValueKey];
                    float diff = firstFoundValue - fValue;
                    [resultsDict setValue:[NSNumber numberWithFloat:diff] forKey:kDifferentialKey];
                    break;
                }
            }
        }
        
    }
    return resultsDict;
}


+ (NSNumber *)valueForType:(NSString *)value result:(Results *)result
{
    if ([value isEqualToString:kCD4])
        return result.CD4;
    else if ([value isEqualToString:kCD4Percent])
        return result.CD4Percent;
    else if ([value isEqualToString:kViralLoad])
        return result.ViralLoad;
    else if ([value isEqualToString:kSystole])
        return result.Systole;
    else if ([value isEqualToString:kDiastole])
        return result.Diastole;
    else if ([value isEqualToString:kHDL])
        return result.HDL;
    else if ([value isEqualToString:kLDL])
        return result.LDL;
    else if ([value isEqualToString:kOxygenLevel])
        return result.OxygenLevel;
    else if ([value isEqualToString:kHeartRate])
        return result.HeartRate;
    else if ([value isEqualToString:kTotalCholesterol])
        return result.TotalCholesterol;
    else if ([value isEqualToString:kTriglyceride])
        return result.Triglyceride;
    else if ([value isEqualToString:kGlucose])
        return result.Glucose;
    else if ([value isEqualToString:kHemoglobulin])
        return result.Hemoglobulin;
    else if ([value isEqualToString:kHepCViralLoad])
        return result.HepCViralLoad;
    else if ([value isEqualToString:kPlateletCount])
        return result.PlateletCount;
    else if ([value isEqualToString:kWhiteBloodCellCount])
        return result.WhiteBloodCellCount;

    //to be changed once the RedBloodCellCount is in the DB
    else if ([value isEqualToString:kRedBloodCellCount])
        return nil;
    
    else
        return nil;
}



@end
