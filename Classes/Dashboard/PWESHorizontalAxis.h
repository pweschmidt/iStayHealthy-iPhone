//
//  PWESHorizontalAxis.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 25/05/2014.
//
//

#import "PWESAxis.h"

@class PWESDataNTuple;

@interface PWESHorizontalAxis : PWESAxis
/**
   horizontal axis
   @param frame
   @param attributes set the tick label and axis label font size and font type
 */
- (id)initHorizontalAxisWithFrame:(CGRect)frame
                       attributes:(NSDictionary *)attributes;

/**
   horizontal axis with default attributes
   @param frame
 */
- (id)initHorizontalAxisWithFrame:(CGRect)frame;

/**
   @param frame
   @param attributes
   @param dateLine
   @param showAtBottom
 */
- (id)initHorizontalAxisWithFrame:(CGRect)frame
                      orientation:(AxisType)orientation
                       attributes:(NSDictionary *)attributes
                           ntuple:(PWESDataNTuple *)ntuple
                     showAtBottom:(BOOL)showAtBottom;
@end
