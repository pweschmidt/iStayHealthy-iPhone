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
#import <CoreText/CoreText.h>

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
@property (nonatomic, assign) BOOL showAxisLabel;

@property (nonatomic, strong) CALayer *axisLayer;

/**
   @param frame
   @param orientation
   @param attributes
 */
- (id)initWithFrame:(CGRect)frame
        orientation:(AxisType)orientation
         attributes:(NSDictionary *)attributes;

/**
   @param style
 */
- (CGFloat)fontSizeForAxisStyle:(AxisStyle)style;

/**
   @param style
 */
- (NSString *)fontNameForAxisStyle:(AxisStyle)style;

/**
   @param line
 */
- (CGSize)sizeOfLine:(CTLineRef)line;

/**
   show the axis
 */
- (void)show;
@end
