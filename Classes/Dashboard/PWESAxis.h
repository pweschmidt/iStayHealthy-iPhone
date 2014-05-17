//
//  PWESAxis.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 14/10/2013.
//
//

#import <Foundation/Foundation.h>
#import "PWESChartsConstants.h"
#import "PWESDraw.h"
#import "PWESValueRange.h"

@interface PWESAxis : PWESDraw
@property (nonatomic, strong) UIColor *axisColor;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) NSString *axisTitle;
@property (nonatomic, assign) AxisType axisTitleOrientation;
@property (nonatomic, assign) AxisType orientation;
@property (nonatomic, assign) CGFloat ticks;
@property (nonatomic, assign) CGFloat tickLabelOffsetX;
@property (nonatomic, assign) CGFloat tickLabelOffsetY;
@property (nonatomic, assign) CGFloat tickLabelOffsetXRight;
@property (nonatomic, assign) CGFloat tickLabelOffsetYRight;
@property (nonatomic, assign) CGFloat exponentialTickLabelOffset;
@property (nonatomic, strong) NSDictionary *axisAttributes;

@property (nonatomic, strong) CALayer *axisLayer;
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
   show the axis
 */
- (void)show;
@end
