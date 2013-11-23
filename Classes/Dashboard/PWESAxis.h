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
@property (nonatomic, strong) NSString *axisTitle;
@property (nonatomic, assign) AxisType axisTitleOrientation;
@property (nonatomic, assign) AxisType orientation;
@property (nonatomic, assign) CGFloat ticks;

@property (nonatomic, strong) CALayer *axisLayer;

/**
 vertical axis
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
 horizontal axis
 @param frame
 */
- (id)initHorizontalAxisWithFrame:(CGRect)frame;

/**
 show the axis
 */
- (void)show;
@end
