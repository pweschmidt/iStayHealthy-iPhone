//
//  HealthChartsView.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 19/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChartEvents;

@interface HealthChartsView : UIView {
	CGFloat dashPattern[2];
	CGFloat medDashPattern[2];
	CGFloat dateDashPattern[3];
    float width;
    float height;
    ChartEvents *events;
}
@property (nonatomic, retain) ChartEvents *events;
- (void)drawXAxis:(CGContextRef)context;
- (void)drawYAxis:(CGContextRef)context;
- (void)drawCD4Ticks:(CGContextRef)context;
- (void)drawCD4PercentTicks:(CGContextRef)context;
- (void)drawViralLoadTicks:(CGContextRef)context atOffset:(float)xOffset;
- (void)drawCD4Labels:(CGContextRef)context atOffset:(float)xOffset;
- (void)drawCD4PercentLabels:(CGContextRef)context atOffset:(float)xOffset;
- (void)drawViralLoadLogLabels:(CGContextRef)context atOffset:(float)xOffset;
- (void)drawCD4Counts:(CGContextRef)context;
- (void)drawCD4Percentages:(CGContextRef)context;
- (void)drawViralLoadCounts:(CGContextRef)context;
- (void)drawMedicationStartLine:(CGContextRef)context;
- (void)drawMissedMedicationWarning:(CGContextRef)context;
- (void)drawStartAndEndDate:(CGContextRef)context;

@end
