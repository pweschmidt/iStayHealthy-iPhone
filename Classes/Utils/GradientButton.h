//
//  GradientButton.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 18/08/2012.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>

enum {
    Red = 0,
    Green = 1,
    Orange = 2,
    White = 256
}ButtonColours;

@interface GradientButton : UIButton
@property (nonatomic, strong) NSArray *normalGradientColors;
@property (nonatomic, strong) NSArray *normalGradientLocations;
@property (nonatomic, strong) NSArray *highlightGradientColors;
@property (nonatomic, strong) NSArray *highlightGradientLocations;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) CGFloat strokeWeight;
@property (nonatomic, strong) UIColor *strokeColor;
+ (GradientButton *)buttonWithFrame:(CGRect)frame title:(NSString *)titleText;
- (id)initWithFrame:(CGRect)frame colour:(int)colourIndex title:(NSString *)titleText;
- (void)setColourIndex:(NSInteger)index;
@end
