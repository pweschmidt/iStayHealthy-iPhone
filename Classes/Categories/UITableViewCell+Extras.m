//
//  UITableViewCell+Extras.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 08/09/2013.
//
//

#import "UITableViewCell+Extras.h"
#import "NSDate+Extras.h"
#import <objc/runtime.h>

static char const * kDateLabel = "DateLabel";

@implementation UITableViewCell (Extras)
- (void)configureCellWithDate:(NSDate *)date
{
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.frame = CGRectMake(20, 2, 55, 55);
    imageView.image = [UIImage imageNamed:@"appointments.png"];
    [self addSubview:imageView];

    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(100, 14, 170, 31);
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor darkGrayColor];
    label.font = [UIFont systemFontOfSize:15];
    if (nil != date)
    {
        label.text = [date stringFromCustomDate];
    }
    else
    {
        label.text = [[NSDate date] stringFromCustomDate];
    }
    [self addSubview:label];
    
    objc_setAssociatedObject(self, kDateLabel, label, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

- (void)updateDate:(NSDate *)date
{
    if (nil == date)
    {
        return;
    }
    UILabel * label = objc_getAssociatedObject(self, kDateLabel);
    if (nil == label)
    {
        return;
    }
    label.text = [date stringFromCustomDate];
//    [label setNeedsDisplay];
}
@end
