//
//  ChartViewPortrait.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 05/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChartView.h"

@interface ChartViewPortrait : ChartView {
	BOOL isCD4;
	UIButton *cd4Button;
	UIButton *viralLoadButton;
	UIImage *cd4On;
	UIImage *cd4Off;
	UIImage *viralOn;
	UIImage *viralOff;
	
}
@property (nonatomic, retain) IBOutlet UIButton *cd4Button;
@property (nonatomic, retain) IBOutlet UIButton *viralLoadButton;
@property (nonatomic, retain) UIImage *cd4On;
@property (nonatomic, retain) UIImage *cd4Off;
@property (nonatomic, retain) UIImage *viralOn;
@property (nonatomic, retain) UIImage *viralOff;
- (void)setLabelsCD4:(CGContextRef)context;
- (void)setLabelsViralLoad:(CGContextRef)context;
- (void)setUpCD4Button;
- (void)setUpViralLoadButton;
- (IBAction) selectCD4:	(id) sender;
- (IBAction) selectViralLoad: (id) sender;

@end
