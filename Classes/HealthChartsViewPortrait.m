//
//  HealthChartsViewPortrait.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 19/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HealthChartsViewPortrait.h"
#import "ChartSettings.h"
#define CD4CHARTSTATE 0
#define CD4PERCENTCHARTSTATE 1
#define VIRALCHARTSTATE 2


@implementation HealthChartsViewPortrait
@synthesize cd4Button, cd4PercentButton, viralLoadButton;

/**
 initWithFrame
 */
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        state = CD4CHARTSTATE;
        [self drawCD4Button];
        [self drawCD4PercentButton];
        [self drawViralLoadButton];
    }
    return self;
}

/**
 drawRect - the main drawing method
 */
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    switch (state) {
        case CD4CHARTSTATE:
            [super drawCD4Ticks:UIGraphicsGetCurrentContext()];
            [super drawCD4Labels:UIGraphicsGetCurrentContext() atOffset:0.0];
            [super drawCD4Counts:UIGraphicsGetCurrentContext()];
            break;
        case CD4PERCENTCHARTSTATE:
            [super drawCD4PercentTicks:UIGraphicsGetCurrentContext()];
            [super drawCD4PercentLabels:UIGraphicsGetCurrentContext() atOffset:0.0];
            [super drawCD4Percentages:UIGraphicsGetCurrentContext()];
            break;
        case VIRALCHARTSTATE:
            [super drawViralLoadTicks:UIGraphicsGetCurrentContext() atOffset:MARGINLEFT];
            [super drawViralLoadLogLabels:UIGraphicsGetCurrentContext() atOffset:0.0];
            [super drawViralLoadCounts:UIGraphicsGetCurrentContext()];
            break;
    }
}

- (void)showCD4{
	state = CD4CHARTSTATE;
	[self.cd4Button setBackgroundImage:[UIImage imageNamed:@"cd4On-small.png"] forState:UIControlStateNormal];
	[self.cd4PercentButton setBackgroundImage:[UIImage imageNamed:@"cd4PercentOff-small.png"] forState:UIControlStateNormal];
	[self.viralLoadButton setBackgroundImage:[UIImage imageNamed:@"viralOff-small.png"] forState:UIControlStateNormal];
	[self setNeedsDisplay];
    
}
- (void)showCD4Percent{
	state = CD4PERCENTCHARTSTATE;
	[self.cd4Button setBackgroundImage:[UIImage imageNamed:@"cd4Off-small.png"] forState:UIControlStateNormal];
	[self.cd4PercentButton setBackgroundImage:[UIImage imageNamed:@"cd4PercentOn-small.png"] forState:UIControlStateNormal];
	[self.viralLoadButton setBackgroundImage:[UIImage imageNamed:@"viralOff-small.png"] forState:UIControlStateNormal];
	[self setNeedsDisplay];    
    
}
- (void)showViralLoad{
	state = VIRALCHARTSTATE;
	[self.cd4Button setBackgroundImage:[UIImage imageNamed:@"cd4Off-small.png"] forState:UIControlStateNormal];
	[self.cd4PercentButton setBackgroundImage:[UIImage imageNamed:@"cd4PercentOff-small.png"] forState:UIControlStateNormal];
	[self.viralLoadButton setBackgroundImage:[UIImage imageNamed:@"viralOn-small.png"] forState:UIControlStateNormal];
	[self setNeedsDisplay];
    
}

/**
 selectCD4
 */
- (IBAction) selectCD4:	(id) sender{
	state = CD4CHARTSTATE;
	[self.cd4Button setBackgroundImage:[UIImage imageNamed:@"cd4On-small.png"] forState:UIControlStateNormal];
	[self.cd4PercentButton setBackgroundImage:[UIImage imageNamed:@"cd4PercentOff-small.png"] forState:UIControlStateNormal];
	[self.viralLoadButton setBackgroundImage:[UIImage imageNamed:@"viralOff-small.png"] forState:UIControlStateNormal];
	[self setNeedsDisplay];
    
}

/**
 selectCD4Percent
 */
- (IBAction) selectCD4Percent: (id) sender{
	state = CD4PERCENTCHARTSTATE;
	[self.cd4Button setBackgroundImage:[UIImage imageNamed:@"cd4Off-small.png"] forState:UIControlStateNormal];
	[self.cd4PercentButton setBackgroundImage:[UIImage imageNamed:@"cd4PercentOn-small.png"] forState:UIControlStateNormal];
	[self.viralLoadButton setBackgroundImage:[UIImage imageNamed:@"viralOff-small.png"] forState:UIControlStateNormal];
	[self setNeedsDisplay];    
}

/**
 selectViralLoad
 */
- (IBAction) selectViralLoad: (id) sender{
	state = VIRALCHARTSTATE;
	[self.cd4Button setBackgroundImage:[UIImage imageNamed:@"cd4Off-small.png"] forState:UIControlStateNormal];
	[self.cd4PercentButton setBackgroundImage:[UIImage imageNamed:@"cd4PercentOff-small.png"] forState:UIControlStateNormal];
	[self.viralLoadButton setBackgroundImage:[UIImage imageNamed:@"viralOn-small.png"] forState:UIControlStateNormal];
	[self setNeedsDisplay];
}

/**
 drawCD4Button
 */
- (void)drawCD4Button{
    CGRect frame = CGRectMake(CGRectGetMinX(self.bounds)+ 30.0, CGRectGetMinY(self.bounds) + 1.0, 80.0, 20.0);
	self.cd4Button = [UIButton buttonWithType:UIButtonTypeCustom];
	[self.cd4Button setFrame:frame];
	[self.cd4Button addTarget:self action:@selector(selectCD4:) forControlEvents:UIControlEventTouchUpInside];
	[self.cd4Button setBackgroundImage:[UIImage imageNamed:@"cd4On-small.png"] forState:UIControlStateNormal];
	[self addSubview:cd4Button];
}

/**
 drawCD4PercentButton
 */
- (void)drawCD4PercentButton{
    CGRect frame = CGRectMake(CGRectGetMinX(self.bounds)+ 115.0, CGRectGetMinY(self.bounds) + 1.0, 50.0, 20.0);
	self.cd4PercentButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[self.cd4PercentButton setFrame:frame];
	[self.cd4PercentButton addTarget:self action:@selector(selectCD4Percent:) forControlEvents:UIControlEventTouchUpInside];
	[self.cd4PercentButton setBackgroundImage:[UIImage imageNamed:@"cd4PercentOff-small.png"] forState:UIControlStateNormal];
	[self addSubview:cd4PercentButton];    
}

/**
 drawViralLoadButton
 */
- (void)drawViralLoadButton{
    CGRect frame = CGRectMake(CGRectGetMinX(self.bounds)+ 170.0, CGRectGetMinY(self.bounds) + 1.0, 80.0, 20.0);
	self.viralLoadButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[self.viralLoadButton setFrame:frame];
	[self.viralLoadButton addTarget:self action:@selector(selectViralLoad:) forControlEvents:UIControlEventTouchUpInside];
	[self.viralLoadButton setBackgroundImage:[UIImage imageNamed:@"viralOff-small.png"] forState:UIControlStateNormal];
	[self addSubview:viralLoadButton];        
}


/**
 dealloc
 */
- (void)dealloc
{
    self.cd4Button = nil;
    self.cd4PercentButton = nil;
    self.viralLoadButton = nil;
    [super dealloc];
}

@end
