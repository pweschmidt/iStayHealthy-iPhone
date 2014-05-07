//
//  PWESStar.m
//  SeinfeldCalendarWithLayers
//
//  Created by Peter Schmidt on 25/04/2014.
//  Copyright (c) 2014 Peter Schmidt. All rights reserved.
//

#import "PWESStar.h"

@interface PWESStar ()
@property (nonatomic, strong) UIColor *colour;
@end

@implementation PWESStar

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		// Initialization code
	}
	return self;
}

+ (PWESStar *)starWithColourAndFrame:(CGRect)frame;
{
	PWESStar *star = [[PWESStar alloc] initWithFrame:frame];
	star.colour = DARK_YELLOW;
	star.backgroundColor = [UIColor clearColor];
	return star;
}

+ (PWESStar *)starWithoutColourAndFrame:(CGRect)frame;
{
	PWESStar *star = [[PWESStar alloc] initWithFrame:frame];
	star.colour = [UIColor lightGrayColor];
	star.backgroundColor = [UIColor clearColor];
	return star;
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGFloat radius = self.bounds.size.width / 2;
	CGFloat angle = 36 * M_PI / 180;
	CGFloat halfAngle = 18 * M_PI / 180;

	CGContextBeginPath(context);
	CGContextSetLineWidth(context, 1.0);
	CGContextSetStrokeColorWithColor(context, self.colour.CGColor);
	CGContextSetFillColorWithColor(context, self.colour.CGColor);

	CGPoint centre = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);

	/**
	   1st point
	 */
	CGPoint one = CGPointMake(self.bounds.origin.x + radius, 0);

	/**
	   2nd point
	 */
	CGFloat x2 = centre.x + radius * sin(angle);
	CGFloat y2 = centre.y + radius * cos(angle);
	CGPoint two = CGPointMake(x2, y2);

	/**
	   3rd point
	 */
	CGFloat x3 = centre.x - radius * cos(halfAngle);
	CGFloat y3 = centre.y - radius * sin(halfAngle);
	CGPoint three = CGPointMake(x3, y3);

	/**
	   4th point
	 */
	CGPoint four = CGPointMake(centre.x + radius * cos(halfAngle), y3);

	/**
	   5th point
	 */
	CGPoint five = CGPointMake(centre.x - radius * sin(angle), y2);

	CGContextMoveToPoint(context, one.x, one.y);
	CGContextAddLineToPoint(context, two.x, two.y);
	CGContextAddLineToPoint(context, three.x, three.y);
	CGContextAddLineToPoint(context, four.x, four.y);
	CGContextAddLineToPoint(context, five.x, five.y);
	CGContextAddLineToPoint(context, one.x, one.y);
	CGContextClosePath(context);
	CGContextFillPath(context);
}

@end
