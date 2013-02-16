//
//  ResultSegmentedCell.m
//  iStayHealthy
//
//  Created by peterschmidt on 05/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ResultSegmentedCell.h"

@implementation ResultSegmentedCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
    }
    return self;
}

- (void)setDelegate:(id)viewControllerDelegate
{
    [super setDelegate:viewControllerDelegate];
}

- (IBAction)isUndetectable:(id)sender
{
    if (self.switchControl.isOn)
    {
        super.inputValueField.text = NSLocalizedString(@"undetectable", @"undetectable");
        super.inputValueField.enabled = NO;
        [super.resultValueDelegate setValueString:NSLocalizedString(@"undetectable", @"undetectable") withTag:self.tag];
    }
    else
    {
        super.inputValueField.text = @"";
        super.inputValueField.enabled = YES;
        [super.resultValueDelegate setValueString:@"" withTag:self.tag];        
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
