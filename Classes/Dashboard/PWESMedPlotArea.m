//
//  PWESMedPlotArea.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 18/05/2014.
//
//

#import "PWESMedPlotArea.h"

@implementation PWESMedPlotArea
- (id)initWithFrame:(CGRect)frame
         lineColour:(UIColor *)lineColour
           dateLine:(NSArray *)dateLine
{
	PWESMedPlotArea *area = [[PWESMedPlotArea alloc] initWithFrame:frame
	                                                    lineColour:lineColour
	                                                    valueRange:nil
	                                                      dateLine:dateLine];
	return area;
}

- (void)plotMedicationTuple:(PWESDataTuple *)tuple
{
}

- (void)plotMissedMedicationTuple:(PWESDataTuple *)tuple
{
}

@end
