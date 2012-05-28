//
//  HealthChartsViewPortrait.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 19/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HealthChartsView.h"

@interface HealthChartsViewPortrait : HealthChartsView {
	UIButton *cd4Button;
    UIButton *cd4PercentButton;
	UIButton *viralLoadButton;
    NSUInteger state;
}
@property (nonatomic, strong) IBOutlet UIButton *cd4Button;
@property (nonatomic, strong) IBOutlet UIButton *cd4PercentButton;
@property (nonatomic, strong) IBOutlet UIButton *viralLoadButton;
- (void)drawCD4Button;
- (void)drawCD4PercentButton;
- (void)drawViralLoadButton;
- (IBAction) selectCD4:	(id) sender;
- (IBAction) selectCD4Percent: (id) sender;
- (IBAction) selectViralLoad: (id) sender;
- (void)showCD4;
- (void)showCD4Percent;
- (void)showViralLoad;
@end
