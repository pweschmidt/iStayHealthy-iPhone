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

- (id)initWithFrame:(CGRect)frame
         lineColour:(UIColor *)lineColour
         valueRange:(PWESValueRange *)valueRange
           dateLine:(NSArray *)dateLine
              ticks:(CGFloat)ticks;

- (void)plotDataTuple:(PWESDataTuple *)tuple;
@end
