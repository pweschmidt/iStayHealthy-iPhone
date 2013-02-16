//
//  HealthChartsViewLandscape.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 19/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HealthChartsViewLandscape.h"
#import "ChartSettings.h"
#import "GeneralSettings.h"
#import "Trafo.h"

@implementation HealthChartsViewLandscape
/**
 */
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self drawCD4Title];
        [self drawViralLoadTitle];
    }
    return self;
}

/**
 */
- (void)drawCD4Title
{
	float xValue = CGRectGetMinX(self.bounds)  + 55.0;
	float yValue = CGRectGetMinY(self.bounds) + 3.0;
	self.cd4TitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(xValue, yValue, 100.0, 15.5)];
	self.cd4TitleLabel.text = NSLocalizedString(@"CD4 Count",nil);
	self.cd4TitleLabel.textColor = DARK_YELLOW;
	self.cd4TitleLabel.backgroundColor = BRIGHT_BACKGROUND;
	[self addSubview:self.cd4TitleLabel];    
}

/**
 */
- (void)drawViralLoadTitle
{
	float xValue = CGRectGetMinX(self.bounds)  + width - 100.0;
	float yValue = CGRectGetMinY(self.bounds) + 3.0;
	self.viralLoadTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(xValue, yValue, 100.0, 15.5)];
	self.viralLoadTitleLabel.text = NSLocalizedString(@"Viral Load",nil);
	self.viralLoadTitleLabel.textColor = DARK_BLUE;
	self.viralLoadTitleLabel.backgroundColor = BRIGHT_BACKGROUND;
	[self addSubview:self.viralLoadTitleLabel];    
}


/**
 */
- (void)drawRightYAxis:(CGContextRef)context
{
	CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
	CGContextSetLineWidth(context, 2.0);
	CGContextMoveToPoint(context, width, MARGINTOP);
	CGContextAddLineToPoint(context, width, height + MARGINTOP);
	CGContextStrokePath(context);        
}

- (void)drawGridLines:(CGContextRef)context
{
	CGContextSetLineWidth(context, 1.0);
	CGContextSetLineDash(context, 0, dateDashPattern, DASHCOUNT);
	CGContextSetRGBStrokeColor(context, 0.8, 0.8, 0.8, 1.0);
	CGContextSetRGBFillColor(context, 0.8, 0.8, 0.8, 1.0);

    for (int tick = 1; tick < CD4TICKS ; ++tick)
    {
        float yOffset = [Trafo mapCD4CountToYAxis:(100*tick) forHeight:height];
#ifdef APPDEBUG
//        NSLog(@"drawCD4Ticks: tick=%d yOffset=%f",tick,yOffset);
#endif
		CGContextMoveToPoint(context, MARGINLEFT, yOffset);
		CGContextAddLineToPoint(context,width, yOffset);
		CGContextStrokePath(context);
    }
	
    CGContextSetLineDash(context, 0, nil, 0);	
    
}


/**
 */
- (void)drawRect:(CGRect)rect
{    
    [super drawRect:rect];
    [super drawCD4Ticks:UIGraphicsGetCurrentContext()];
    [super drawCD4Labels:UIGraphicsGetCurrentContext() atOffset:MARGINLEFT];
    [super drawCD4Counts:UIGraphicsGetCurrentContext()];
    [self drawRightYAxis:UIGraphicsGetCurrentContext()];
    [self drawGridLines:UIGraphicsGetCurrentContext()];
    [super drawViralLoadTicks:UIGraphicsGetCurrentContext() atOffset:width];
    [super drawViralLoadLogLabels:UIGraphicsGetCurrentContext() atOffset:(width+3.0)];
    [super drawViralLoadCounts:UIGraphicsGetCurrentContext()];
}

/**
 */

@end
