//
//  StarView.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 25/01/2014.
//
//

#import "StarView.h"
#import "Constants.h"
#import "GeneralSettings.h"

@interface StarView ()
@property (nonatomic, assign) BOOL hasPartialFill;
@end

@implementation StarView
+ (StarView *)starViewForFrame:(CGRect)frame hasPartialFill:(BOOL)hasPartialFill
{
    StarView *view = [[StarView alloc] initWithFrame:frame hasPartialFill:hasPartialFill];
    return view;
}

- (id)initWithFrame:(CGRect)frame hasPartialFill:(BOOL)hasPartialFill
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _hasPartialFill = hasPartialFill;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat radius = self.bounds.size.width/2;
    CGFloat angle = 36 * M_PI/180;
    CGFloat halfAngle = 18 * M_PI/180;
    
    CGContextBeginPath(context);
	CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, DARK_YELLOW.CGColor);
    CGContextSetFillColorWithColor(context, DARK_YELLOW.CGColor);
    
    CGPoint centre = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    
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
    CGPoint four = CGPointMake(centre.x + radius *cos(halfAngle), y3);
    
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
