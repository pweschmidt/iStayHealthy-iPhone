//
//  PWESLabelPlotArea.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 25/05/2014.
//
//

#import "PWESLabelPlotArea.h"

@interface PWESLabelPlotArea ()
@property (nonatomic, strong) NSString *label;
@property (nonatomic, strong) UIColor *colour;
@end

@implementation PWESLabelPlotArea
- (id)initWithFrame:(CGRect)frame
              label:(NSString *)label
             colour:(UIColor *)colour
{
	self = [super initWithFrame:frame lineColour:nil valueRange:nil dateLine:nil];
	if (nil != self)
	{
		_label = label;
		_colour = colour;
	}
	return self;
}

- (void)plotLabel
{
}

@end
