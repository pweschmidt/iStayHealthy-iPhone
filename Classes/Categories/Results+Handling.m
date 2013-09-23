//
//  Results+Handling.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 11/08/2013.
//
//

#import "Results+Handling.h"
#import "NSManagedObject+Handling.h"
#import "Constants.h"

@implementation Results (Handling)
- (void)importFromDictionary:(NSDictionary *)attributes
{
    if (nil == attributes || [attributes allKeys].count == 0)
    {
        return;
    }
    
    self.ResultsDate = [self dateFromValue:[attributes objectForKey:kResultsDate]];
    self.CD4 = [self numberFromValue:[attributes objectForKey:kCD4]];
    self.CD4Percent = [self numberFromValue:[attributes objectForKey:kCD4Percent]];
    self.LDL = [self numberFromValue:[attributes objectForKey:kLDL]];
    self.Hemoglobulin = [self numberFromValue:[attributes objectForKey:kHemoglobulin]];
    self.Glucose = [self numberFromValue:[attributes objectForKey:kGlucose]];
    self.HeartRate = [self numberFromValue:[attributes objectForKey:kHeartRate]];
    self.OxygenLevel = [self numberFromValue:[attributes objectForKey:kOxygenLevel]];
    self.UID = [attributes objectForKey:kUID];
    self.Systole = [self numberFromValue:[attributes objectForKey:kSystole]];
    self.PlateletCount = [self numberFromValue:[attributes objectForKey:kPlatelet]];
    self.HDL = [self numberFromValue:[attributes objectForKey:kHDL]];
    self.HepCViralLoad = [self numberFromValue:[attributes objectForKey:kHepCViralLoad]];
    self.Weight = [self numberFromValue:[attributes objectForKey:kWeight]];
    self.Diastole = [self numberFromValue:[attributes objectForKey:kDiastole]];
    self.WhiteBloodCellCount = [self numberFromValue:[attributes objectForKey:kWhiteBloodCells]];
    self.TotalCholesterol = [self numberFromValue:[attributes objectForKey:kTotalCholesterol]];
    self.Triglyceride = [self numberFromValue:[attributes objectForKey:kTriglyceride]];
    self.ViralLoad = [self numberFromValue:[attributes objectForKey:kViralLoad]];
    self.redBloodCellCount = [self numberFromValue:[attributes objectForKey:kRedBloodCells]];
    self.cholesterolRatio = [self numberFromValue:[attributes objectForKey:kCholesterolRatio]];
    self.cardiacRiskFactor = [self numberFromValue:[attributes objectForKey:kCardiacRiskFactor]];
    self.liverAlanineTransaminase = [self numberFromValue:[attributes objectForKey:kLiverAlanineTransaminase]];
    self.liverAspartateTransaminase = [self numberFromValue:[attributes objectForKey:kLiverAspartateTransaminase]];
    self.liverAlkalinePhosphatase = [self numberFromValue:[attributes objectForKey:kLiverAlkalinePhosphatase]];
    self.liverAlbumin = [self numberFromValue:[attributes objectForKey:kLiverAlbumin]];
    self.liverAlanineTotalBilirubin = [self numberFromValue:[attributes objectForKey:kLiverAlanineTotalBilirubin]];
    self.liverAlanineDirectBilirubin = [self numberFromValue:[attributes objectForKey:kLiverAlanineDirectBilirubin]];
    self.liverGammaGlutamylTranspeptidase = [self numberFromValue:[attributes objectForKey:kLiverGammaGlutamylTranspeptidase]];
    self.hepBTiter = [NSNumber numberWithInt:-1];
    self.hepCTiter = [NSNumber numberWithInt:-1];
    
}
- (NSString *)xmlString
{
    NSMutableString *string = [NSMutableString string];
    [string appendString:[self xmlOpenForElement:NSStringFromClass([self class])]];
    [string appendString:[self xmlAttributeString:kResultsDate attributeValue:self.ResultsDate]];
    [string appendString:[self xmlAttributeString:kCD4 attributeValue:self.CD4]];
    [string appendString:[self xmlAttributeString:kCD4Percent attributeValue:self.CD4Percent]];
    [string appendString:[self xmlAttributeString:kLDL attributeValue:self.LDL]];
    [string appendString:[self xmlAttributeString:kHemoglobulin attributeValue:self.Hemoglobulin]];
    [string appendString:[self xmlAttributeString:kGlucose attributeValue:self.Glucose]];
    [string appendString:[self xmlAttributeString:kHeartRate attributeValue:self.HeartRate]];
    [string appendString:[self xmlAttributeString:kOxygenLevel attributeValue:self.OxygenLevel]];
    [string appendString:[self xmlAttributeString:kSystole attributeValue:self.Systole]];
    [string appendString:[self xmlAttributeString:kPlatelet attributeValue:self.PlateletCount]];
    [string appendString:[self xmlAttributeString:kHDL attributeValue:self.HDL]];
    [string appendString:[self xmlAttributeString:kHepCViralLoad attributeValue:self.HepCViralLoad]];
    [string appendString:[self xmlAttributeString:kDiastole attributeValue:self.Diastole]];
    [string appendString:[self xmlAttributeString:kWhiteBloodCells attributeValue:self.WhiteBloodCellCount]];
    [string appendString:[self xmlAttributeString:kTotalCholesterol attributeValue:self.TotalCholesterol]];
    [string appendString:[self xmlAttributeString:kTriglyceride attributeValue:self.Triglyceride]];
    [string appendString:[self xmlAttributeString:kViralLoad attributeValue:self.ViralLoad]];
    [string appendString:[self xmlAttributeString:kRedBloodCells attributeValue:self.redBloodCellCount]];
    [string appendString:[self xmlAttributeString:kCholesterolRatio attributeValue:self.cholesterolRatio]];
    [string appendString:[self xmlAttributeString:kCardiacRiskFactor attributeValue:self.cardiacRiskFactor]];
    [string appendString:[self xmlAttributeString:kWeight attributeValue:self.Weight]];
    [string appendString:[self xmlAttributeString:kLiverAlanineTransaminase attributeValue:self.liverAlanineTransaminase]];
    [string appendString:[self xmlAttributeString:kLiverAspartateTransaminase attributeValue:self.liverAspartateTransaminase]];
    [string appendString:[self xmlAttributeString:kLiverAlkalinePhosphatase attributeValue:self.liverAlkalinePhosphatase]];
    [string appendString:[self xmlAttributeString:kLiverAlbumin attributeValue:self.liverAlbumin]];
    [string appendString:[self xmlAttributeString:kLiverAlanineTotalBilirubin attributeValue:self.liverAlanineTotalBilirubin]];
    [string appendString:[self xmlAttributeString:kLiverAlanineDirectBilirubin attributeValue:self.liverAlanineDirectBilirubin]];
    [string appendString:[self xmlAttributeString:kLiverGammaGlutamylTranspeptidase attributeValue:self.liverGammaGlutamylTranspeptidase]];
    [string appendString:[self xmlAttributeString:kUID attributeValue:self.UID]];
    [string appendString:@"/>\r"];
    return string;
}

- (void)addValueString:(NSString *)valueString type:(NSString *)type
{
    NSNumber *value = nil;
    if (nil == valueString || [valueString isEqualToString:@""])
    {
        value = [NSNumber numberWithFloat:0.0];
    }
    else
    {
        value = [NSNumber numberWithFloat:[valueString floatValue]];
    }
    if ([type isEqualToString:kCD4])
    {
        self.CD4 = value;
    }
    else if ([type isEqualToString:kCD4Percent])
    {
        self.CD4Percent = value;
    }
    else if ([type isEqualToString:kLDL])
    {
        self.LDL = value;
    }
    else if ([type isEqualToString:kHemoglobulin])
    {
        self.Hemoglobulin = value;
    }
    else if ([type isEqualToString:kGlucose])
    {
        self.Glucose = value;
    }
    else if ([type isEqualToString:kHeartRate])
    {
        self.HeartRate = value;
    }
    else if ([type isEqualToString:kOxygenLevel])
    {
        self.OxygenLevel = value;
    }
    else if ([type isEqualToString:kSystole])
    {
        self.Systole = value;
    }
    else if ([type isEqualToString:kPlatelet])
    {
        self.PlateletCount = value;
    }
    else if ([type isEqualToString:kHDL])
    {
        self.HDL = value;
    }
    else if ([type isEqualToString:kHepCViralLoad])
    {
        self.HepCViralLoad = value;
    }
    else if ([type isEqualToString:kDiastole])
    {
        self.Diastole = value;
    }
    else if ([type isEqualToString:kWhiteBloodCells])
    {
        self.WhiteBloodCellCount = value;
    }
    else if ([type isEqualToString:kTotalCholesterol])
    {
        self.TotalCholesterol = value;
    }
    else if ([type isEqualToString:kTriglyceride])
    {
        self.Triglyceride = value;
    }
    else if ([type isEqualToString:kViralLoad])
    {
        self.ViralLoad = value;
    }
    else if ([type isEqualToString:kRedBloodCells])
    {
        self.redBloodCellCount = value;
    }
    else if ([type isEqualToString:kCholesterolRatio])
    {
        self.cholesterolRatio = value;
    }
    else if ([type isEqualToString:kCardiacRiskFactor])
    {
        self.cardiacRiskFactor = value;
    }
    else if ([type isEqualToString:kWeight])
    {
        self.Weight = value;
    }
    else if ([type isEqualToString:kLiverAlanineTransaminase])
    {
        self.liverAlanineTransaminase = value;
    }
    else if ([type isEqualToString:kLiverAspartateTransaminase])
    {
        self.liverAspartateTransaminase = value;
    }
    else if ([type isEqualToString:kLiverAlkalinePhosphatase])
    {
        self.liverAlkalinePhosphatase = value;
    }
    else if ([type isEqualToString:kLiverAlbumin])
    {
        self.liverAlbumin = value;
    }
    else if ([type isEqualToString:kLiverAlanineTotalBilirubin])
    {
        self.liverAlanineTotalBilirubin = value;
    }
    else if ([type isEqualToString:kLiverAlanineDirectBilirubin])
    {
        self.liverAlanineDirectBilirubin = value;
    }
    else if ([type isEqualToString:kLiverGammaGlutamylTranspeptidase])
    {
        self.liverGammaGlutamylTranspeptidase = value;
    }
}


@end
