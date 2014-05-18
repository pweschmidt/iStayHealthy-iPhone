//
//  PWESMedPlotArea.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 18/05/2014.
//
//

#import "PWESPlotArea.h"
#import "PWESChartsConstants.h"
#import "PWESDataTuple.h"
#import "PWESValueRange.h"

@interface PWESMedPlotArea : PWESPlotArea
/**
   @param frame
   @param dateLine
   @param ticks
 */
- (id)initWithFrame:(CGRect)frame
           dateLine:(NSArray *)dateLine;

/**
   plots a vertical gray dashed medication line for a given tuple
   the line will be drawn at the start date
   @param tuple
 */
- (void)plotMedicationTuple:(PWESDataTuple *)tuple;

/**
   plots a vertical red dashed medication line for a given tuple
   the line will be drawn at the end date
   @param tuple
 */
- (void)plotMissedMedicationTuple:(PWESDataTuple *)tuple;

@end
