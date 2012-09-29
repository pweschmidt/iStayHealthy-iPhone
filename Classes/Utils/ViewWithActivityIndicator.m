//
//  ViewWithActivityIndicator.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 29/09/2012.
//
//

#import "ViewWithActivityIndicator.h"
#import <QuartzCore/QuartzCore.h>

@implementation ViewWithActivityIndicator
@synthesize activityIndicator = _activityIndicator;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 10;
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        CGRect activityFrame = CGRectMake(65, 40, self.activityIndicator.bounds.size.width, self.activityIndicator.bounds.size.height);
        self.activityIndicator.frame = activityFrame;
        [self addSubview:self.activityIndicator];
        
        CGRect labelFrame = CGRectMake(20, 115, 130, 22);
        UILabel *captionLabel = [[UILabel alloc] initWithFrame:labelFrame];
        captionLabel.backgroundColor = [UIColor clearColor];
        captionLabel.textColor = [UIColor whiteColor];
        captionLabel.textAlignment = UITextAlignmentCenter;
        captionLabel.text = NSLocalizedString(@"Loading", @"Loading");
        [self addSubview:captionLabel];
    }
    return self;
}

- (void)stop
{
    if ([self.activityIndicator isAnimating])
    {
        [self.activityIndicator stopAnimating];
    }
    [self removeFromSuperview];
}


- (id)init
{
    CGRect frame = CGRectMake(75, 155, 170, 170);
    return [self initWithFrame:frame];
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
