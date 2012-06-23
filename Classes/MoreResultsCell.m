//
//  MoreResultsCell.m
//  iStayHealthy
//
//  Created by peterschmidt on 23/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MoreResultsCell.h"

@implementation MoreResultsCell
@synthesize colourCodeView = _colourCodeView;
@synthesize moreTitleLabel = _moreTitleLabel;
@synthesize hasMoreLabel = _hasMoreLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
