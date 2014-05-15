//
//  PWESDraw.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 15/10/2013.
//
//

#import <Foundation/Foundation.h>

@interface PWESDraw : NSObject
{
	CGFloat dashPattern[2];
	CGFloat medDashPattern[2];
	CGFloat dateDashPattern[3];
}
- (void)drawLineWithContext:(CGContextRef)context
                      start:(CGPoint)start
                        end:(CGPoint)end
                  lineWidth:(CGFloat)lineWidth
                   cgColour:(CGColorRef)cgColour;

- (void)drawLineWithContext:(CGContextRef)context
                      start:(CGPoint)start
                        end:(CGPoint)end
                  lineWidth:(CGFloat)lineWidth
                   cgColour:(CGColorRef)cgColour
                 fillColour:(CGColorRef)fillColour;

- (void)drawLineWithContext:(CGContextRef)context
                      start:(CGPoint)start
                        end:(CGPoint)end
                  lineWidth:(CGFloat)lineWidth
                   cgColour:(CGColorRef)cgColour
                 fillColour:(CGColorRef)fillColour
                    pattern:(CGFloat *)pattern
               patternCount:(int)patternCount;

- (void)drawRectWithContext:(CGContextRef)context
                      point:(CGPoint)point
                   cgColour:(CGColorRef)cgColor
                 fillColour:(CGColorRef)fillColour;

- (void)drawRectWithContext:(CGContextRef)context
                      point:(CGPoint)point
                      width:(CGFloat)width
                     height:(CGFloat)height
                   cgColour:(CGColorRef)cgColor
                 fillColour:(CGColorRef)fillColour;

@end
