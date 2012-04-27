//
//  Trafo.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 19/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Trafo.h"


@implementation Trafo
/**
 shifts the log value by 1. So instead of 100 we would get 10, if the shiftBy factor is set to 1.
 */
+ (float)logValue:(float)y shiftBy:(float)value{
    return ( (0.0 < y) ? ( y - value ) : y);
}

/**
 linear scaling factor
 */
+ (float)scaleYValue:(float)y by:(float)yMax{
    return (y / yMax);
}


/**
 returns the lowest integer multiple
 */
+ (float)yValue:(float)y forTicks:(float)ticks{
    int iYValue = y/ticks;
    return (iYValue * ticks);
}

/**
 maps the cd4 count value to the y-axis 
 */
+ (float)mapCD4CountToYAxis:(float)cd4Value forHeight:(float)height{
	if (MAXCD4COUNT < cd4Value) {
		cd4Value = MAXCD4COUNT;
	}
    float maxYValue = [Trafo yValue:height forTicks:CD4TICKS];
	float yValue = cd4Value * [Trafo scaleYValue:maxYValue by:MAXCD4COUNT];
	return (height + MARGINTOP - yValue);
}


/**
 maps the cd4% value to the y-axis
 */
+ (float)mapCD4PercentToYAxis:(float)cd4PercentValue forHeight:(float)height{
    if (MAXCD4PERCENT < cd4PercentValue) {
        cd4PercentValue = MAXCD4PERCENT;
    }
    float maxYValue = [Trafo yValue:height forTicks:CD4PERCENTTICKS];
    float yValue = cd4PercentValue * [Trafo scaleYValue:maxYValue by:MAXCD4PERCENT];
    return (height + MARGINTOP - yValue);
}

/**
 takes the actual viral load value, converts it into log_10 based value and maps the log10(viralload) value
 to the y-axis
 */
+ (float)mapLogViralLoadToYAxis:(float)viralLoadValue forHeight:(float)height{
	float maxLogValue = log10(MAXVIRALLOAD);

	if (0.0 == viralLoadValue) {
		viralLoadValue = 1.0;
	}
	if (MAXVIRALLOAD < viralLoadValue) {
		viralLoadValue = MAXVIRALLOAD;
	}
    float maxYValue = [Trafo yValue:height forTicks:VIRALLOADTICKS];
    float logValue = [Trafo logValue:log10f(viralLoadValue) shiftBy:0.0];

	float yValue = logValue * [Trafo scaleYValue:maxYValue by:maxLogValue];
	yValue = height + MARGINTOP - yValue;
	return yValue;
}

+ (float)xStart:(float)width forCount:(int)count{
    float xStart = (width/count);    
    if (10 > count) {
        xStart = width/(count + 1);
    }
    if (xStart < MARGINLEFT) {
        xStart = MARGINLEFT;
    }  
    return xStart;
}


@end
