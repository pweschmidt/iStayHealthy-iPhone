//
//  UIImageResizer.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 15/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIImageResizer.h"


@implementation UIImage (Resize)

- (UIImage*)scaleToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, size.width, size.height), self.CGImage);
    
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;
}
@end
