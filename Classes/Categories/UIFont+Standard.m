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
	NSString *name = kDefaultFont;
	switch (fontType)
	{
		case Standard:
			name = kDefaultLightFont;
			break;

		case Light:
			name = kDefaultUltraLightFont;
			break;

		case LightItalic:
			name = kDefaultItalicFont;
			break;

		case Bold:
			name = kDefaultBoldFont;
			break;

		case BoldItalic:
			name = kDefaultBoldItalicFont;
			break;
	}
	return [UIFont fontWithName:name size:size];
}

@end
