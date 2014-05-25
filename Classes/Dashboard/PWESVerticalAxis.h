//
//  PWESVerticalAxis.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 25/05/2014.
//
//

#import "PWESAxis.h"

@interface PWESVerticalAxis : PWESAxis
/**
   vertical axis with default axis attributes
   @param frame
   @param valueRange
   @param orientation
   @param attributes set the tick label and axis label font size and font type
   @param ticks
 */
- (id)initVerticalAxisWithFrame:(CGRect)frame
                     valueRange:(PWESValueRange *)valueRange
                    orientation:(AxisType)orientation
                     attributes:(NSDictionary *)attributes
                          ticks:(CGFloat)ticks;

/**
   vertical axis with default axis attributes
   @param frame
   @param valueRange
   @param orientation
   @param ticks
 */
- (id)initVerticalAxisWithFrame:(CGRect)frame
                     valueRange:(PWESValueRange *)valueRange
                    orientation:(AxisType)orientation
                          ticks:(CGFloat)ticks;

/**
   vertical log10 axis with default axis attributes
   @param frame
   @param valueRange
   @param orientation
   @param logTickDistance
 */
- (id)initVerticalLogAxisWithFrame:(CGRect)frame
                        valueRange:(PWESValueRange *)valueRane
                       orientation:(AxisType)orientation
                   logTickDistance:(CGFloat)logTickDistance;


/**
   vertical axis without labels and no ticks
   @param frame
   @param orientation
 */
- (id)initVerticalAxisWithFrame:(CGRect)frame
                    orientation:(AxisType)orientation;
/**
   vertical axis without labels and no ticks
   @param frame
   @param orientation
   @param attributes set the tick label and axis label font size and font type
 */
- (id)initVerticalAxisWithFrame:(CGRect)frame
                    orientation:(AxisType)orientation
                     attributes:(NSDictionary *)attributes;

@end
