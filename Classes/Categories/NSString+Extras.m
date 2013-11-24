//
//  NSString+Extras.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 24/11/2013.
//
//

#import "NSString+Extras.h"
#import "Constants.h"

@implementation NSString (Extras)
- (NSString *)valueStringForType:(NSString *)type value:(NSNumber *)value
{
    if (nil == type)
    {
        return NSLocalizedString(@"Enter Value", nil);
    }
    NSString *valueString = NSLocalizedString(@"Enter Value", nil);
    if ([type isEqualToString:kCD4] && 0 < [value floatValue])
    {
        return [NSString stringWithFormat:@"%d",[value intValue]];
    }
    else if ([type isEqualToString:kCD4Percent] && 0 < [value floatValue])
    {
        return [NSString stringWithFormat:@"%3.2f",[value floatValue]];
    }
    else if ([type isEqualToString:kLDL] && 0 < [value floatValue])
    {
        return [NSString stringWithFormat:@"%3.2f",[value floatValue]];
    }
    else if ([type isEqualToString:kHemoglobulin] && 0 < [value floatValue])
    {
        return [NSString stringWithFormat:@"%3.2f",[value floatValue]];
    }
    else if ([type isEqualToString:kGlucose] && 0 < [value floatValue])
    {
        return [NSString stringWithFormat:@"%3.2f",[value floatValue]];
    }
    else if ([type isEqualToString:kHeartRate] && 0 < [value floatValue])
    {
        return [NSString stringWithFormat:@"%d",[value intValue]];
    }
    else if ([type isEqualToString:kOxygenLevel] && 0 < [value floatValue])
    {
        return [NSString stringWithFormat:@"%3.2f",[value floatValue]];
    }
    else if ([type isEqualToString:kSystole] && 0 < [value floatValue])
    {
        return [NSString stringWithFormat:@"%d",[value intValue]];
    }
    else if ([type isEqualToString:kPlatelet] && 0 < [value floatValue])
    {
        return [NSString stringWithFormat:@"%9.2f",[value floatValue]];
    }
    else if ([type isEqualToString:kHDL] && 0 < [value floatValue])
    {
        return [NSString stringWithFormat:@"%3.2f",[value floatValue]];
    }
    else if ([type isEqualToString:kHepCViralLoad] && 0 < [value floatValue])
    {
        if (0 == [value floatValue])
        {
            return NSLocalizedString(@"und.", nil);
        }
        else
        {
            return [NSString stringWithFormat:@"%d",[value intValue]];
        }
    }
    else if ([type isEqualToString:kDiastole] && 0 < [value floatValue])
    {
        return [NSString stringWithFormat:@"%d",[value intValue]];
    }
    else if ([type isEqualToString:kWhiteBloodCells] && 0 < [value floatValue])
    {
        return [NSString stringWithFormat:@"%9.2f",[value floatValue]];
    }
    else if ([type isEqualToString:kTotalCholesterol] && 0 < [value floatValue])
    {
        return [NSString stringWithFormat:@"%3.2f",[value floatValue]];
    }
    else if ([type isEqualToString:kTriglyceride] && 0 < [value floatValue])
    {
        return [NSString stringWithFormat:@"%3.2f",[value floatValue]];
    }
    else if ([type isEqualToString:kViralLoad] && 0 <= [value floatValue])
    {
        if (0 == [value floatValue])
        {
            return NSLocalizedString(@"undetectable", nil);
        }
        else
        {
            return [NSString stringWithFormat:@"%d",[value intValue]];
        }
    }
    else if ([type isEqualToString:kRedBloodCells] && 0 < [value floatValue])
    {
        return [NSString stringWithFormat:@"%9.2f",[value floatValue]];
    }
    else if ([type isEqualToString:kCholesterolRatio] && 0 < [value floatValue])
    {
        return [NSString stringWithFormat:@"%3.2f",[value floatValue]];
    }
    else if ([type isEqualToString:kCardiacRiskFactor] && 0 < [value floatValue])
    {
        return [NSString stringWithFormat:@"%3.2f",[value floatValue]];
    }
    else if ([type isEqualToString:kWeight] && 0 < [value floatValue])
    {
        return [NSString stringWithFormat:@"%3.2f",[value floatValue]];
    }
    else if ([type isEqualToString:kBMI] /* && 0 < [self.BMI floatValue] */)
    {
        //return [NSString stringWithFormat:@"%3.2f",[self.BMI floatValue]);
    }
    else if ([type isEqualToString:kLiverAlanineTransaminase] && 0 < [value floatValue])
    {
        return [NSString stringWithFormat:@"%6.2f",[value floatValue]];
    }
    else if ([type isEqualToString:kLiverAspartateTransaminase] && 0 < [value floatValue])
    {
        return [NSString stringWithFormat:@"%6.2f",[value floatValue]];
    }
    else if ([type isEqualToString:kLiverAlkalinePhosphatase] && 0 < [value floatValue])
    {
        return [NSString stringWithFormat:@"%6.2f",[value floatValue]];
    }
    else if ([type isEqualToString:kLiverAlbumin] && 0 < [value floatValue])
    {
        return [NSString stringWithFormat:@"%6.2f",[value floatValue]];
    }
    else if ([type isEqualToString:kLiverAlanineTotalBilirubin] && 0 < [value floatValue])
    {
        return [NSString stringWithFormat:@"%6.2f",[value floatValue]];
    }
    else if ([type isEqualToString:kLiverAlanineDirectBilirubin] && 0 < [value floatValue])
    {
        return [NSString stringWithFormat:@"%6.2f",[value floatValue]];
    }
    else if ([type isEqualToString:kLiverGammaGlutamylTranspeptidase] && 0 < [value floatValue])
    {
        return [NSString stringWithFormat:@"%6.2f",[value floatValue]];
    }
    return valueString;
}

- (NSString *)valueStringForType:(NSString *)type valueAsFloat:(CGFloat)valueAsFloat
{
    return [self valueStringForType:type value:[NSNumber numberWithFloat:valueAsFloat]];
}

@end
