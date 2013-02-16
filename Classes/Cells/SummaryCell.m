//
//  SummaryCell.m
//  iStayHealthy
//
//  Created by peterschmidt on 11/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SummaryCell.h"
#import "GeneralSettings.h"
#import <QuartzCore/QuartzCore.h>

@interface SummaryCell ()
@property (nonatomic, strong) CALayer * addedLayer;
- (CAShapeLayer *)upwardTriangleWithColour:(UIColor *)colour;
- (CAShapeLayer *)downwardTriangleWithColour:(UIColor *)colour;
- (CALayer *)circle;
@end

@implementation SummaryCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)clearIndicatorsFromLayer
{
    if (nil != self.addedLayer)
    {
        [self.addedLayer removeFromSuperlayer];
    }    
}


-(IBAction)indicator:(id)sender hasShape:(NSInteger)shapeIndex isGood:(BOOL)isGood
{
    self.changeIndicatorView.backgroundColor = [UIColor clearColor];
    switch (shapeIndex)
    {
        case neutral:
        {
            CALayer *neutralLayer = [self circle];
            [self.changeIndicatorView.layer addSublayer:neutralLayer];
            self.addedLayer = neutralLayer;
            break;
        }
        case upward:
        {
            CAShapeLayer *shape = nil;
            if (isGood)
            {
                shape = [self upwardTriangleWithColour:DARK_GREEN];
            }
            else
            {
                shape = [self upwardTriangleWithColour:DARK_RED];
            }
            [self.changeIndicatorView.layer addSublayer:shape];
            self.addedLayer = shape;
            break;
        }
        case downward:
        {
            CAShapeLayer *shape = nil;
            if (isGood)
            {
                shape = [self downwardTriangleWithColour:DARK_GREEN];
            }
            else
            {
                shape = [self downwardTriangleWithColour:DARK_RED];
            }
            [self.changeIndicatorView.layer addSublayer:shape];
            self.addedLayer = shape;
            break;
        }
    }
}

- (CAShapeLayer *)upwardTriangleWithColour:(UIColor *)colour
{
    CGSize size = self.changeIndicatorView.bounds.size;
    float width = size.width;
    float height = size.height;
    float midPoint = width / 2;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, midPoint, 0.0);
    CGPathAddLineToPoint(path, NULL, width, height);
    CGPathAddLineToPoint(path, NULL, 0.0, height);
    CGPathAddLineToPoint(path, NULL, midPoint, 0.0);
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = path;
    layer.fillColor = colour.CGColor;
    layer.strokeColor = [UIColor lightGrayColor].CGColor;
    layer.anchorPoint = CGPointMake(0, 0);
    layer.position = CGPointMake(0, 0);
    layer.bounds = self.changeIndicatorView.bounds;
    layer.shadowOffset = CGSizeMake(0, 2);
    layer.shadowRadius = 2;
    layer.shadowOpacity = 0.5;
    layer.shadowColor = [UIColor darkGrayColor].CGColor;
    if (path)
    {
        CGPathRelease(path);
    }
    return layer;
}

- (CAShapeLayer *)downwardTriangleWithColour:(UIColor *)colour
{
    CGSize size = self.changeIndicatorView.bounds.size;
    float width = size.width;
    float height = size.height;
    float midPoint = width / 2;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0.0, 0.0);
    CGPathAddLineToPoint(path, NULL, width, 0.0);
    CGPathAddLineToPoint(path, NULL, midPoint, height);
    CGPathAddLineToPoint(path, NULL, 0.0, 0.0);
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = path;
    layer.fillColor = colour.CGColor;
    layer.strokeColor = [UIColor lightGrayColor].CGColor;
    layer.anchorPoint = CGPointMake(0, 0);
    layer.position = CGPointMake(0, 0);
    layer.bounds = self.changeIndicatorView.bounds;
    layer.shadowOffset = CGSizeMake(0, 2);
    layer.shadowRadius = 2;
    layer.shadowOpacity = 0.5;
    layer.shadowColor = [UIColor darkGrayColor].CGColor;
    if (path)
    {
        CGPathRelease(path);
    }
    return layer;
}

- (CALayer *)circle
{
    CALayer *layer = [CALayer layer];
    CGSize size = self.changeIndicatorView.bounds.size;
    float width = size.width;
    layer.bounds = self.changeIndicatorView.bounds;
    layer.cornerRadius = width/2;
    layer.backgroundColor = [UIColor darkGrayColor].CGColor;
    layer.position = CGPointMake(0, 0);
    layer.anchorPoint = CGPointMake(0, 0);
    layer.shadowOffset = CGSizeMake(0, 2);
    layer.shadowRadius = 2;
    layer.shadowOpacity = 0.5;
    layer.shadowColor = [UIColor darkGrayColor].CGColor;
    return layer;
}


@end
