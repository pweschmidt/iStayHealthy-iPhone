//
//  PWESHorizontalAxis.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 25/05/2014.
//
//

#import "PWESHorizontalAxis.h"
#import "PWESDataNTuple.h"


@interface PWESHorizontalAxis ()
@property (nonatomic, assign) BOOL hasLabels;
@property (nonatomic, strong) PWESDataNTuple *ntuple;
@property (nonatomic, assign) BOOL showAtBottom;
@end

@implementation PWESHorizontalAxis
- (id)initHorizontalAxisWithFrame:(CGRect)frame
{
	return [self initHorizontalAxisWithFrame:frame
	                             orientation:Horizontal
	                              attributes:nil
	                                  ntuple:nil
	                            showAtBottom:YES];
}

- (id)initHorizontalAxisWithFrame:(CGRect)frame attributes:(NSDictionary *)attributes
{
	return [self initHorizontalAxisWithFrame:frame
	                             orientation:Horizontal
	                              attributes:attributes
	                                  ntuple:nil
	                            showAtBottom:YES];
}

- (id)initHorizontalAxisWithFrame:(CGRect)frame
                      orientation:(AxisType)orientation
                       attributes:(NSDictionary *)attributes
                           ntuple:(PWESDataNTuple *)ntuple
                     showAtBottom:(BOOL)showAtBottom
{
	self = [super initWithFrame:frame orientation:orientation attributes:attributes];
	if (nil != self)
	{
		_showAtBottom = YES;
		_ntuple = ntuple;
		self.ticks = 0;
		self.hasLabels = NO;
	}
	return self;
}

- (void)drawLayer:(CALayer *)layer
        inContext:(CGContextRef)context
{
	CGPoint axisStart;
	CGPoint axisEnd;

	CGRect frame = self.axisLayer.bounds;
	axisStart = CGPointMake(frame.origin.x + kAxisLineWidth / 2, frame.origin.y + frame.size.height / 2 - kAxisLineWidth / 2);
	axisEnd = CGPointMake(frame.size.width, frame.origin.y + frame.size.height / 2 - kAxisLineWidth / 2);
	[self drawLineWithContext:context start:axisStart end:axisEnd lineWidth:kAxisLineWidth cgColour:self.axisColor.CGColor];
}

@end
