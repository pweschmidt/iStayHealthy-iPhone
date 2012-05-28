//
//  HealthChartsViewLandscape.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 19/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HealthChartsView.h"

@interface HealthChartsViewLandscape : HealthChartsView {
	UILabel *cd4TitleLabel;
	UILabel *viralLoadTitleLabel;    
}
@property (nonatomic, strong) IBOutlet UILabel *cd4TitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *viralLoadTitleLabel;
- (void)drawRightYAxis:(CGContextRef)context;
- (void)drawCD4Title;
- (void)drawViralLoadTitle;
- (void)drawGridLines:(CGContextRef)context;

@end
