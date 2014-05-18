//
//  PWESPlotArea.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 15/10/2013.
//
//

#import "PWESDraw.h"
#import "PWESChartsConstants.h"
#import "PWESDataTuple.h"
#import "PWESValueRange.h"

@interface PWESPlotArea : PWESDraw
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, strong) CALayer *plotLayer;
@property (nonatomic, strong) NSArray *dateLine;
@property (nonatomic, strong) PWESDataTuple *tuple;
@property (nonatomic, strong) PWESValueRange *valueRange;

/**
   @param frame
   @param lineColour
   @param valueRange
   @param dateLine
   @param ticks
 */
- (id)initWithFrame:(CGRect)frame
         lineColour:(UIColor *)lineColour
         valueRange:(PWESValueRange *)valueRange
           dateLine:(NSArray *)dateLine;

/**
   plots a results line for a given tuple
   @param tuple
 */
- (void)plotDataTuple:(PWESDataTuple *)tuple;

@end
