//
//  Trafo.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 19/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChartSettings.h"


@interface Trafo : NSObject
+ (float)mapCD4CountToYAxis:(float)cd4Value forHeight:(float)height;
+ (float)mapCD4PercentToYAxis:(float)cd4PercentValue forHeight:(float)height;
+ (float)mapLogViralLoadToYAxis:(float)viralLoadValue forHeight:(float)height;
+ (float)yValue:(float)y forTicks:(float)ticks;
+ (float)logValue:(float)y shiftBy:(float)value;
+ (float)scaleYValue:(float)y by:(float)yMax;
+ (float)xStart:(float)width forCount:(int)count;
@end
