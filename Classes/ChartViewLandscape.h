//
//  ChartViewLandscape.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 05/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChartView.h"


@interface ChartViewLandscape : ChartView {
	UILabel *cd4TitleLabel;
	UILabel *viralLoadTitleLabel;
}
@property (nonatomic, retain) IBOutlet UILabel *cd4TitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *viralLoadTitleLabel;
- (void)setUpYAxisViralLoad:(CGContextRef)context;
- (void)setLabelsCD4:(CGContextRef)context;
- (void)setLabelsViralLoad:(CGContextRef)context;
- (void)setUpCD4Label;
- (void)setUpViralLoadLabel;
@end
