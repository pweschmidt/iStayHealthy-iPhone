//
//  RepeatCell.m
//  iStayHealthy
//
//  Created by peterschmidt on 10/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RepeatCell.h"

@implementation RepeatCell

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
    self.repeatCellDelegate = viewControllerDelegate;    
}

- (IBAction)toggleRepeats:(id)sender
{
    [self.repeatCellDelegate setRepeats:self.segmentedControl.selectedSegmentIndex + 1];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
