//
//  Results+Handling.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 11/08/2013.
//
//

#import "Results+Handling.h"
#import "PWESCalendar.h"

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

- (NSDictionary *)dictionaryForAttributes
{
	__block NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	NSDictionary *attributes = [[self entity] attributesByName];
	[attributes enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
	    if (nil != obj)
	    {
	        if ([obj isKindOfClass:[NSNumber class]])
	        {
	            NSNumber *number = (NSNumber *)obj;
	            [dictionary setObject:[NSString stringWithFormat:@"%f", [number floatValue]] forKey:key];
			}
	        else if ([obj isKindOfClass:[NSDate class]])
	        {
	            NSDate *date = (NSDate *)obj;
	            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	            formatter.dateFormat = kDefaultDateFormatting;
	            [dictionary setObject:[NSString stringWithFormat:@"%@", [formatter stringFromDate:date]] forKey:key];
			}
	        else if ([obj isKindOfClass:[NSString class]])
	        {
	            [dictionary setObject:obj forKey:key];
			}
		}
	}];
	return dictionary;
}

- (BOOL)isEqualToDictionary:(NSDictionary *)attributes
{
	if (nil == attributes || [attributes allKeys].count == 0)
	{
		return NO;
	}
	BOOL isSame = NO;
	isSame = [self.UID isEqualToString:[self stringFromValue:[attributes objectForKey:kUID]]];
	if (isSame)
	{
		return YES;
	}

	NSDate *date = [self dateFromValue:[attributes objectForKey:kResultsDate]];
	isSame = [[PWESCalendar sharedInstance] datesAreWithinDays:1.0 date1:date date2:self.ResultsDate];
	return isSame;
}

- (NSString *)xmlString
{
	NSMutableString *string = [NSMutableString string];
	[string appendString:[self xmlOpenForElement:kResult]];
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

- (NSString *)csvString
{
	NSMutableString *string = [NSMutableString string];
	NSDictionary *attributes = [[self entity] attributesByName];
	[attributes enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
	    if (nil != obj && ![key isEqualToString:kUID])
	    {
	        if ([obj isKindOfClass:[NSDate class]])
	        {
	            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	            formatter.dateFormat = kDefaultDateFormatting;
	            [string appendString:[formatter stringFromDate:(NSDate *)obj]];
	            [string appendString:@"\t"];
			}
	        else if ([obj isKindOfClass:[NSNumber class]])
	        {
	            NSNumber *number = (NSNumber *)obj;
	            if (0 < [number floatValue])
	            {
	                [string appendString:[NSString stringWithFormat:@"%9.2f", [number floatValue]]];
	                [string appendString:@"\t"];
				}
			}
	        else if ([obj isKindOfClass:[NSString class]])
	        {
	            [string appendString:obj];
	            [string appendString:@"\t"];
			}
		}
	}];


	[string appendString:@"\r\n"];
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
	else if ([type isEqualToString:kBMI])
	{
		self.bmi = value;
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

- (NSString *)valueStringForType:(NSString *)type
{
	if (nil == type)
	{
		return NSLocalizedString(@"Enter Value", nil);
	}
	NSString *valueString = NSLocalizedString(@"Enter Value", nil);
	if ([type isEqualToString:kCD4] && 0 < [self.CD4 floatValue])
	{
		return [NSString stringWithFormat:@"%d", [self.CD4 intValue]];
	}
	else if ([type isEqualToString:kCD4Percent] && 0 < [self.CD4Percent floatValue])
	{
		return [NSString stringWithFormat:@"%3.2f", [self.CD4Percent floatValue]];
	}
	else if ([type isEqualToString:kLDL] && 0 < [self.LDL floatValue])
	{
		return [NSString stringWithFormat:@"%3.2f", [self.LDL floatValue]];
	}
	else if ([type isEqualToString:kHemoglobulin] && 0 < [self.Hemoglobulin floatValue])
	{
		return [NSString stringWithFormat:@"%3.2f", [self.Hemoglobulin floatValue]];
	}
	else if ([type isEqualToString:kGlucose] && 0 < [self.Glucose floatValue])
	{
		return [NSString stringWithFormat:@"%3.2f", [self.Glucose floatValue]];
	}
	else if ([type isEqualToString:kHeartRate] && 0 < [self.HeartRate floatValue])
	{
		return [NSString stringWithFormat:@"%d", [self.HeartRate intValue]];
	}
	else if ([type isEqualToString:kOxygenLevel] && 0 < [self.OxygenLevel floatValue])
	{
		return [NSString stringWithFormat:@"%3.2f", [self.OxygenLevel floatValue]];
	}
	else if ([type isEqualToString:kSystole] && 0 < [self.Systole floatValue])
	{
		return [NSString stringWithFormat:@"%d", [self.Systole intValue]];
	}
	else if ([type isEqualToString:kPlatelet] && 0 < [self.PlateletCount floatValue])
	{
		return [NSString stringWithFormat:@"%9.2f", [self.PlateletCount floatValue]];
	}
	else if ([type isEqualToString:kHDL] && 0 < [self.HDL floatValue])
	{
		return [NSString stringWithFormat:@"%3.2f", [self.HDL floatValue]];
	}
	else if ([type isEqualToString:kHepCViralLoad] && 0 < [self.HepCViralLoad floatValue])
	{
		if (0 == [self.HepCViralLoad floatValue])
		{
			return NSLocalizedString(@"undetectable", nil);
		}
		else
		{
			return [NSString stringWithFormat:@"%d", [self.HepCViralLoad intValue]];
		}
	}
	else if ([type isEqualToString:kDiastole] && 0 < [self.Diastole floatValue])
	{
		return [NSString stringWithFormat:@"%d", [self.Diastole intValue]];
	}
	else if ([type isEqualToString:kWhiteBloodCells] && 0 < [self.WhiteBloodCellCount floatValue])
	{
		return [NSString stringWithFormat:@"%9.2f", [self.WhiteBloodCellCount floatValue]];
	}
	else if ([type isEqualToString:kTotalCholesterol] && 0 < [self.TotalCholesterol floatValue])
	{
		return [NSString stringWithFormat:@"%3.2f", [self.TotalCholesterol floatValue]];
	}
	else if ([type isEqualToString:kTriglyceride] && 0 < [self.Triglyceride floatValue])
	{
		return [NSString stringWithFormat:@"%3.2f", [self.Triglyceride floatValue]];
	}
	else if ([type isEqualToString:kViralLoad] && 0 < [self.ViralLoad floatValue])
	{
		if (0 == [self.ViralLoad floatValue])
		{
			return NSLocalizedString(@"undetectable", nil);
		}
		else
		{
			return [NSString stringWithFormat:@"%d", [self.ViralLoad intValue]];
		}
	}
	else if ([type isEqualToString:kRedBloodCells] && 0 < [self.redBloodCellCount floatValue])
	{
		return [NSString stringWithFormat:@"%9.2f", [self.redBloodCellCount floatValue]];
	}
	else if ([type isEqualToString:kCholesterolRatio] && 0 < [self.cholesterolRatio floatValue])
	{
		return [NSString stringWithFormat:@"%3.2f", [self.cholesterolRatio floatValue]];
	}
	else if ([type isEqualToString:kCardiacRiskFactor] && 0 < [self.cardiacRiskFactor floatValue])
	{
		return [NSString stringWithFormat:@"%3.2f", [self.cardiacRiskFactor floatValue]];
	}
	else if ([type isEqualToString:kWeight] && 0 < [self.Weight floatValue])
	{
		return [NSString stringWithFormat:@"%3.2f", [self.Weight floatValue]];
	}
	else if ([type isEqualToString:kBMI]  && 0 < [self.bmi floatValue])
	{
		return [NSString stringWithFormat:@"%3.2f", [self.bmi floatValue]];
	}
	else if ([type isEqualToString:kLiverAlanineTransaminase] && 0 < [self.liverAlanineTransaminase floatValue])
	{
		return [NSString stringWithFormat:@"%6.2f", [self.liverAlanineTransaminase floatValue]];
	}
	else if ([type isEqualToString:kLiverAspartateTransaminase] && 0 < [self.liverAspartateTransaminase floatValue])
	{
		return [NSString stringWithFormat:@"%6.2f", [self.liverAspartateTransaminase floatValue]];
	}
	else if ([type isEqualToString:kLiverAlkalinePhosphatase] && 0 < [self.liverAlkalinePhosphatase floatValue])
	{
		return [NSString stringWithFormat:@"%6.2f", [self.liverAlkalinePhosphatase floatValue]];
	}
	else if ([type isEqualToString:kLiverAlbumin] && 0 < [self.liverAlbumin floatValue])
	{
		return [NSString stringWithFormat:@"%6.2f", [self.liverAlbumin floatValue]];
	}
	else if ([type isEqualToString:kLiverAlanineTotalBilirubin] && 0 < [self.liverAlanineTotalBilirubin floatValue])
	{
		return [NSString stringWithFormat:@"%6.2f", [self.liverAlanineTotalBilirubin floatValue]];
	}
	else if ([type isEqualToString:kLiverAlanineDirectBilirubin] && 0 < [self.liverAlanineDirectBilirubin floatValue])
	{
		return [NSString stringWithFormat:@"%6.2f", [self.liverAlanineDirectBilirubin floatValue]];
	}
	else if ([type isEqualToString:kLiverGammaGlutamylTranspeptidase] && 0 < [self.liverGammaGlutamylTranspeptidase floatValue])
	{
		return [NSString stringWithFormat:@"%6.2f", [self.liverGammaGlutamylTranspeptidase floatValue]];
	}
	return valueString;
}

@end
