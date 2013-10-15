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
            name = @"HelveticaNeue-Light";
            break;
        case Light:
            name = @"HelveticaNeue-UltraLight";
            break;
        case LightItalic:
            name = @"HelveticaNeue-LightOblique";
            break;
        case Bold:
            name = @"HelveticaNeue-Bold";
            break;
        case BoldItalic:
            name = @"HelveticaNeue-BoldOblique";
            break;
    }
    return [UIFont fontWithName:name size:size];
}
@end
