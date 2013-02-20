//
//  Results+Comparator.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 17/02/2013.
//
//

#import "Results+Comparator.h"

@implementation Results (Comparator)
- (BOOL)isEqualTo:(id)dataObject
{
    Results *results = nil;
    if ([dataObject isKindOfClass:[Results class]])
    {
        results = (Results *)dataObject;
    }
    else
    {
        return NO;
    }
    if ([self isEqual:results])
    {
        return YES;
    }
    if ([self.UID isEqualToString:results.UID])
    {
        return YES;
    }
    NSUInteger comparator = 0;
    NSUInteger index = 0;
    
    comparator++;
    if ([self.ResultsDate compare:results.ResultsDate] == NSOrderedSame)
    {
        index++;
    }
    
    if (self.CD4 && results.CD4)
    {
        comparator++;
        if ([self.CD4 isEqualToNumber:results.CD4])
        {
            index++;
        }
    }

    if (self.CD4Percent && results.CD4Percent)
    {
        comparator++;
        if ([self.CD4Percent isEqualToNumber:results.CD4Percent])
        {
            index++;
        }
    }

    if (self.ViralLoad && results.ViralLoad)
    {
        comparator++;
        if ([self.ViralLoad isEqualToNumber:results.ViralLoad])
        {
            index++;
        }
    }

    if (self.HepCViralLoad && results.HepCViralLoad)
    {
        comparator++;
        if ([self.HepCViralLoad isEqualToNumber:results.HepCViralLoad])
        {
            index++;
        }
    }

    
    if (self.HDL && results.HDL)
    {
        comparator++;
        if ([self.HDL isEqualToNumber:results.HDL])
        {
            index++;
        }
    }

    if (self.LDL && results.LDL)
    {
        comparator++;
        if ([self.LDL isEqualToNumber:results.LDL])
        {
            index++;
        }
    }

    if (self.cardiacRiskFactor && results.cardiacRiskFactor)
    {
        comparator++;
        if ([self.cardiacRiskFactor isEqualToNumber:results.cardiacRiskFactor])
        {
            index++;
        }
    }
    
    if (self.cholesterolRatio && results.cholesterolRatio)
    {
        comparator++;
        if ([self.cholesterolRatio isEqualToNumber:results.cholesterolRatio])
        {
            index++;
        }
    }

    if (self.TotalCholesterol && results.TotalCholesterol)
    {
        comparator++;
        if ([self.TotalCholesterol isEqualToNumber:results.TotalCholesterol])
        {
            index++;
        }
    }

    if (self.Glucose && results.Glucose)
    {
        comparator++;
        if ([self.Glucose isEqualToNumber:results.Glucose])
        {
            index++;
        }
    }

    if (self.Weight && results.Weight)
    {
        comparator++;
        if ([self.Weight isEqualToNumber:results.Weight])
        {
            index++;
        }
    }
    
    if (self.Systole && results.Systole && self.Diastole && results.Diastole)
    {
        comparator++;
        if ([self.Systole isEqualToNumber:results.Systole] &&
            [self.Diastole isEqualToNumber:results.Diastole])
        {
            index++;
        }
    }
    
    if (self.Hemoglobulin && results.Hemoglobulin)
    {
        comparator++;
        if ([self.Hemoglobulin isEqualToNumber:results.Hemoglobulin])
        {
            index++;
        }
    }
    
    if (self.redBloodCellCount && results.redBloodCellCount)
    {
        comparator++;
        if ([self.redBloodCellCount isEqualToNumber:results.redBloodCellCount])
        {
            index++;
        }
    }
    
    if (self.WhiteBloodCellCount && results.WhiteBloodCellCount)
    {
        comparator++;
        if ([self.WhiteBloodCellCount isEqualToNumber:results.WhiteBloodCellCount])
        {
            index++;
        }
    }

    if (self.PlateletCount && results.PlateletCount)
    {
        comparator++;
        if ([self.PlateletCount isEqualToNumber:results.PlateletCount])
        {
            index++;
        }
    }
    
    return (comparator == index) ? YES : NO;
}
@end
