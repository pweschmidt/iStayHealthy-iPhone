//
//  BaseCollectionViewCell.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/11/2013.
//
//

#import "BaseCollectionViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation BaseCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.layer.cornerRadius = 6;
        self.layer.borderColor = [UIColor blueColor].CGColor;
        self.layer.borderWidth = 2;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
