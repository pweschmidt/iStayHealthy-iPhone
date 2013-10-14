//
//  PWESAxis.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 14/10/2013.
//
//

#import <Foundation/Foundation.h>
#import "PWESChartsConstants.h"

@interface PWESAxis : NSObject
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, strong) UIColor *axisColor;
@property (nonatomic, strong) NSString *axisTitle;
@property (nonatomic, assign) AxisType axisTitleOrientation;
@property (nonatomic, assign) CGFloat tickLength;
@property (nonatomic, assign) CGFloat pxTickDistance;
@property (nonatomic, assign) AxisType orientation;

@property (nonatomic, strong) CALayer *axisLayer;

- (id)initWithFrame:(CGRect)frame
        orientation:(AxisType)orientation;
- (void)configureAxis;
- (void)show;
@end
