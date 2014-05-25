//
//  PWESResultDatesPlotArea.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 25/05/2014.
//
//

#import "PWESPlotArea.h"
@class PWESDataNTuple;

@interface PWESResultDatesPlotArea : PWESPlotArea
/**
   @param frame
   @param marginBottom
   @param ntuple
 */
- (id)initWithFrame:(CGRect)frame
       marginBottom:(CGFloat)marginBottom
             ntuple:(PWESDataNTuple *)ntuple;

/**
 */
- (void)plotDates;
@end
