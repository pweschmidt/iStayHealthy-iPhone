//
//  FAQDetailCell.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 27/04/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FAQDetailCell.h"


@implementation FAQDetailCell
@synthesize explanationView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUpExplanationView];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setUpExplanationView{
	CGRect frame = CGRectMake(CGRectGetMinX(self.bounds)+20.0, CGRectGetMinY(self.bounds)+7.5, 255.0, 85.0);
	UITextView *view = [[UITextView alloc] initWithFrame:frame];
    view.textColor = [UIColor darkGrayColor];
	view.textAlignment = UITextAlignmentLeft;
	view.font = [UIFont systemFontOfSize:11.0];
    view.editable = NO;

	self.explanationView = view;
	[self.contentView addSubview:self.explanationView];
	[view release];	        
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
    [explanationView release];
    [super dealloc];
}

@end
