//
//  ChartViewPortrait.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 05/01/2011.
//  Copyright 2011 pweschmidt. All rights reserved.
//

#import "ChartViewPortrait.h"
#import "ChartSettings.h"
#import "GeneralSettings.h"
#import "Results.h"

@implementation ChartViewPortrait
@synthesize cd4Button, viralLoadButton, cd4On, cd4Off, viralOn, viralOff;

/**
 sets up the reference frame for the chart view in portrait mode
 @frame 
 */
- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		maxCD4Value = 700.0;
		maxViralLoadValue = 10000000.0;
		isCD4 = YES;
		isInLandscape = NO;		
		cd4On = [[UIImage imageNamed:@"cd4On-small.png"]retain];    
		cd4Off = [[UIImage imageNamed:@"cd4Off-small.png"]retain];
		viralOn = [[UIImage imageNamed:@"viralOn-small.png"]retain];
		viralOff = [[UIImage imageNamed:@"viralOff-small.png"]retain];
		
		[self setUpCD4Button];
		[self setUpViralLoadButton];
	}
    return self;
}
#pragma mark -
#pragma mark Label settings

/**
 sets the labels for the CD4 count
 @context 
 */
- (void)setLabelsCD4:(CGContextRef)context{
	CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));
	CGContextSelectFont(context, LABELFONTTYPE, LABELFONTSIZESMALL, kCGEncodingMacRoman);
	CGContextSetTextDrawingMode(context, kCGTextStroke);
	for (int tick = 1; tick <= TICKS; ++tick) {
		int cd4Value = tick * 100;
		if (200 >= cd4Value) {
			CGContextSetRGBStrokeColor(context, 0.8, 0.0, 0.0, 1.0);
			CGContextSetRGBFillColor(context, 0.8, 0.0, 0.0, 1.0);
		}
		else if(400 > cd4Value){
			CGContextSetRGBStrokeColor(context, 1.0, 0.4, 0.0, 1.0);
			CGContextSetRGBFillColor(context, 1.0, 0.4, 0.0, 1.0);
		}
		else {
			CGContextSetRGBStrokeColor(context, 0.0, 0.4, 0.0, 1.0);
			CGContextSetRGBFillColor(context, 0.0, 0.4, 0.0, 1.0);
		}


		
		NSString *cd4Label = [NSString stringWithFormat:@"%d",cd4Value];
		float majorYOffset = [self scaledYCD4ValueAsFloat:(float)cd4Value] - 2.0;
		CGContextShowTextAtPoint(context, 0.0, majorYOffset, [cd4Label UTF8String], [cd4Label length]);
	}
}
/**
 sets the labels for the Viral Load count. This will be in the format of e.g. 10^2 (instead of 100)
 @context 
 */
- (void)setLabelsViralLoad:(CGContextRef)context{
	CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));
	float exponential = 10.0;
	for (int tick = 1; tick <= TICKS; ++tick) {
		float majorYOffset = [self scaledYViralLoadLogValueAsFloat:exponential];
		float xOffset = 0.0;
		if (3 > tick) {
			CGContextSetRGBStrokeColor(context, 0.0, 0.4, 0.0, 1.0);
			CGContextSetRGBFillColor(context, 0.0, 0.4, 0.0, 1.0);
		}
		else if (6 > tick){
			CGContextSetRGBStrokeColor(context, 1.0, 0.4, 0.0, 1.0);
			CGContextSetRGBFillColor(context, 1.0, 0.4, 0.0, 1.0);
		}
		else {
			CGContextSetRGBStrokeColor(context, 0.8, 0.0, 0.0, 1.0);
			CGContextSetRGBFillColor(context, 0.8, 0.0, 0.0, 1.0);
		}

				
		if (3 > tick) {
			NSString *vlLabel = [NSString stringWithFormat:@"%d",(int)exponential];
			CGContextSelectFont(context, LABELFONTTYPE, LABELFONTSIZESMALL, kCGEncodingMacRoman);
			CGContextSetTextDrawingMode(context, kCGTextStroke);
			CGContextShowTextAtPoint(context, xOffset, majorYOffset, [vlLabel UTF8String], [vlLabel length]);
		}
		else {
			NSString *vlLogLabel = [NSString stringWithFormat:@"10"];
			NSString *vlExponent = [NSString stringWithFormat:@"%d",tick];
			CGContextSelectFont(context, LABELFONTTYPE, LABELFONTSIZESMALL, kCGEncodingMacRoman);
			CGContextSetTextDrawingMode(context, kCGTextStroke);
			CGContextShowTextAtPoint(context, xOffset, majorYOffset, [vlLogLabel UTF8String], [vlLogLabel length]);
			CGContextSelectFont(context, LABELFONTTYPE, EXPONENTFONTSIZE, kCGEncodingMacRoman);
			CGContextSetTextDrawingMode(context, kCGTextStroke);
			majorYOffset = majorYOffset - 5.0;
			xOffset = xOffset + 12.0;
			CGContextShowTextAtPoint(context, xOffset, majorYOffset, [vlExponent UTF8String], [vlExponent length]);
		}

		exponential *= 10.0;			
	}
}


#pragma mark -
#pragma mark button settings and actions

/**
 the button that allows users to select the CD4 Chart
 */
- (void)setUpCD4Button{
	cd4Button = [UIButton buttonWithType:UIButtonTypeCustom];
	[cd4Button setFrame:CGRectMake(CGRectGetMinX(self.bounds)+ 80.0, CGRectGetMinY(self.bounds) + 3.0, 50.0, 16.0)];
	[cd4Button addTarget:self action:@selector(selectCD4:) forControlEvents:UIControlEventTouchUpInside];
	[cd4Button setBackgroundImage:cd4On forState:UIControlStateNormal];
	
	
	[self addSubview:cd4Button];
}

/**
 the button that allows users to select the Viral Load chart
 */
- (void)setUpViralLoadButton{
	viralLoadButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[viralLoadButton setFrame:CGRectMake(CGRectGetMinX(self.bounds)+ 135.0, CGRectGetMinY(self.bounds) + 3.0, 50.0, 16.0)];
	[viralLoadButton addTarget:self action:@selector(selectViralLoad:) forControlEvents:UIControlEventTouchUpInside];
	[viralLoadButton setBackgroundImage:viralOff forState:UIControlStateNormal];
	
	[self addSubview:viralLoadButton];
}


/**
 action selects CD4 and then redraws the chart
 @id 
 */
- (IBAction) selectCD4:	(id) sender{
	isCD4 = YES;
	[cd4Button setBackgroundImage:cd4On forState:UIControlStateNormal];
	[viralLoadButton setBackgroundImage:viralOff forState:UIControlStateNormal];
	[self setNeedsDisplay];
}

/**
 action selects Viral Load and then redraws the chart
 @id 
 */
- (IBAction) selectViralLoad: (id) sender{
	isCD4 = NO;
	[cd4Button setBackgroundImage:cd4Off forState:UIControlStateNormal];
	[viralLoadButton setBackgroundImage:viralOn forState:UIControlStateNormal];
	[self setNeedsDisplay];
}



#pragma mark -
#pragma mark drawRect

/**
 main drawing method
 unlike in landscape mode we only show 1 chart at a time.
 @rect 
 */
- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	if (isCD4) {
		[self setLabelsCD4:UIGraphicsGetCurrentContext()];
		[super plotCD4Data:UIGraphicsGetCurrentContext()];
	}
	else {
		[self setLabelsViralLoad:UIGraphicsGetCurrentContext()];
		[super plotViralLoadData:UIGraphicsGetCurrentContext()];
	}
	
}

#pragma mark -
#pragma mark dealloc
/**
 dealloc
 */
- (void)dealloc {
	[cd4Button release];
	[viralLoadButton release];
	[cd4On release];
	[cd4Off release];
	[viralOff release];
	[viralOn release];
    [super dealloc];
}


@end
