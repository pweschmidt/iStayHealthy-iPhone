//
//  UIFont+Standard.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 05/10/2013.
//
//

#import "UIFont+Standard.h"

@implementation UIFont (Standard)
+ (UIFont *)fontWithType:(FontType)fontType
                    size:(FontSize)size
{
    NSString *name = @"Helvetica";
    switch (fontType)
    {
        case Standard:
            name = @"Helvetica-Light";
            break;
        case Light:
            name = @"Helvetica-Light";
            break;
        case LightItalic:
            name = @"Helvetica-LightOblique";
            break;
        case Bold:
            name = @"Helvetica-Bold";
            break;
        case BoldItalic:
            name = @"Helvetica-BoldOblique";
            break;
    }
    return [UIFont fontWithName:name size:size];
}
@end
