//
//  ChartView.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 05/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Medication;

@interface ChartView : UIView {
	CGFloat dashPattern[2];
	CGFloat medDashPattern[2];
	CGFloat dateDashPattern[3];
	float width;
	float height;
	float minorTickStart;
	float tickDistance;
	float maxCD4Value;
	float maxViralLoadValue;
	NSMutableArray *allResults;
	NSMutableArray *allMeds;
	NSMutableArray *uniqueDates;
	float maxYValue;
	BOOL isInLandscape;
        
}
@property (nonatomic, retain) NSMutableArray *allResults;
@property (nonatomic, retain) NSMutableArray *allMeds;
@property (nonatomic, retain) NSMutableArray *uniqueDates;
- (void)setUpXAxis:(CGContextRef)context;
- (void)setUpYAxis:(CGContextRef)context;
- (float)nearestTickInterval;
- (float)scaledYCD4Value:(NSNumber *)cd4Value;
- (float)scaledYCD4ValueAsFloat:(float)cd4Value;
- (float)scaledYViralLoadLogValue:(NSNumber *)viralLoadValue;
- (float)scaledYViralLoadLogValueAsFloat:(float)viralLoadValue;
- (void)plotCD4Data:(CGContextRef)context;
- (void)plotViralLoadData:(CGContextRef)context;
- (void)plotMedLine:(CGContextRef)context;
- (void)findUniqueDates;
- (BOOL)isWithinDateRange:(NSDate *)firstDate now:(NSDate *)secondDate;
- (BOOL)startDateIsEarlier:(NSDate *)resultDate medDate:(NSDate *)startDate;
- (NSString *)dateString:(NSDate *)date;
- (void)drawMedImage:(float)xSize with:(float)ySize;
- (void)drawDate:(NSDate *)date xPosition:(float)xOffset;
@end
