//
//  PWESResultsTypes.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 18/05/2014.
//
//

#import "PWESResultsTypes.h"

@interface PWESResultsTypes ()
@property (nonatomic, strong, readwrite) NSString *mainType;
@property (nonatomic, strong, readwrite) NSString *secondaryType;
@property (nonatomic, assign, readwrite) BOOL wantsMedLine;
@property (nonatomic, assign, readwrite) BOOL wantsMissedMedLine;
@property (nonatomic, assign, readwrite) BOOL isDualType;
@end

@implementation PWESResultsTypes
+ (PWESResultsTypes *)resultsTypeWithType:(NSString *)type
                             wantsMedLine:(BOOL)wantsMedLine
                       wantsMissedMedLine:(BOOL)wantsMissedMedLine
{
	PWESResultsTypes *result = [[PWESResultsTypes alloc] init];
	result.mainType = type;
	result.secondaryType = nil;
	result.wantsMedLine = wantsMedLine;
	result.wantsMissedMedLine = wantsMissedMedLine;
	result.isDualType = NO;
	return result;
}

+ (PWESResultsTypes *)resultsTypeWithMainType:(NSString *)mainType
                                secondaryType:(NSString *)secondaryType
                                 wantsMedLine:(BOOL)wantsMedLine
                           wantsMissedMedLine:(BOOL)wantsMissedMedLine
{
	PWESResultsTypes *result = [[PWESResultsTypes alloc] init];
	result.mainType = mainType;
	result.secondaryType = secondaryType;
	result.wantsMedLine = wantsMedLine;
	result.wantsMissedMedLine = wantsMissedMedLine;
	result.isDualType = YES;
	return result;
}

@end
