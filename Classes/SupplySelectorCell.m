//
//  SupplySelectorCell.m
//  iStayHealthy
//
//  Created by peterschmidt on 26/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SupplySelectorCell.h"

@implementation SupplySelectorCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		[self setUpSegmentedLabel];
		[self setUpSegmentedControl];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

/**
 if Yes then the textfield will be disabled
 @sender id of the sending control
 */
- (IBAction)valueChanged:(id)sender
{
#ifdef APPDEBUG
	NSLog(@"segmentAction: selected segment = %d", [sender selectedSegmentIndex]);
#endif
    
	if (0 == [sender selectedSegmentIndex]) {
		editableCellTextField.text = NSLocalizedString(@"undetectable",nil);
		editableCellTextField.enabled = NO;
	}
	else {
		editableCellTextField.enabled = YES;
		editableCellTextField.text = @"";
	}
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
