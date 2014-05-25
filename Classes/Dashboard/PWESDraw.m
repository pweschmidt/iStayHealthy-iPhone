//
//  PWESDraw.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 15/10/2013.
//
//

#import "PWESDraw.h"
#import <CoreText/CoreText.h>


static NSDateFormatter *shortDate()
{
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = kShortDateFormatting;
	formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
	return formatter;
}

@implementation PWESDraw

- (id)init
{
	self = [super init];
	if (nil != self)
	{
		dashPattern[0]      = 2.0;
		dashPattern[1]      = 3.0;

		medDashPattern[0]   = 6.0;
		medDashPattern[1]   = 3.0;

		dateDashPattern[0]  = 1.0;
		dateDashPattern[1]  = 4.0;
		dateDashPattern[2]  = 2.5;
	}
	return self;
}

- (void)drawLineWithContext:(CGContextRef)context
                      start:(CGPoint)start
                        end:(CGPoint)end
                  lineWidth:(CGFloat)lineWidth
                   cgColour:(CGColorRef)cgColour
{
	[self drawLineWithContext:context
	                    start:start
	                      end:end
	                lineWidth:lineWidth
	                 cgColour:cgColour
	               fillColour:nil
	                  pattern:nil
	             patternCount:0];
}

- (void)drawLineWithContext:(CGContextRef)context
                      start:(CGPoint)start
                        end:(CGPoint)end
                  lineWidth:(CGFloat)lineWidth
                   cgColour:(CGColorRef)cgColour
                 fillColour:(CGColorRef)fillColour
{
	[self drawLineWithContext:context
	                    start:start
	                      end:end
	                lineWidth:lineWidth
	                 cgColour:cgColour
	               fillColour:fillColour
	                  pattern:nil
	             patternCount:0];
}

- (void)drawLineWithContext:(CGContextRef)context
                      start:(CGPoint)start
                        end:(CGPoint)end
                  lineWidth:(CGFloat)lineWidth
                   cgColour:(CGColorRef)cgColour
                 fillColour:(CGColorRef)fillColour
                    pattern:(CGFloat *)pattern
               patternCount:(int)patternCount;
{
	CGContextSetLineCap(context, kCGLineCapSquare);
	CGContextSetStrokeColorWithColor(context, cgColour);

	if (nil != fillColour && NULL != fillColour)
	{
		CGContextSetFillColorWithColor(context, fillColour);
	}

	CGContextSetLineWidth(context, lineWidth);

	if (nil != pattern && NULL != pattern && 0 < patternCount)
	{
		CGContextSetLineDash(context, 0.0f, pattern, patternCount);
	}

	CGFloat lineOffset = lineWidth / 2;
	CGContextMoveToPoint(context, start.x + lineOffset, start.y + lineOffset);
	CGContextAddLineToPoint(context, end.x + lineOffset, end.y + lineOffset);
	CGContextStrokePath(context);

	CGContextSetLineDash(context, 0, nil, 0);
}


- (void)drawRectWithContext:(CGContextRef)context
                      point:(CGPoint)point
                   cgColour:(CGColorRef)cgColour
                 fillColour:(CGColorRef)fillColour
{
	[self drawRectWithContext:context
	                    point:point
	                    width:2.0
	                   height:2.0
	                 cgColour:cgColour
	               fillColour:fillColour];
}

- (void)drawRectWithContext:(CGContextRef)context
                      point:(CGPoint)point
                      width:(CGFloat)width
                     height:(CGFloat)height
                   cgColour:(CGColorRef)cgColour
                 fillColour:(CGColorRef)fillColour
{
	CGContextSetStrokeColorWithColor(context, cgColour);

	if (nil != fillColour && NULL != fillColour)
	{
		CGContextSetFillColorWithColor(context, fillColour);
	}
	CGContextSetLineWidth(context, 1.0);
	CGRect rect = CGRectMake(point.x + width / 2.0, point.y + height / 2.0, width, height);
	CGContextAddRect(context, rect);
	CGContextStrokePath(context);
}

- (void)drawDate:(CGContextRef)context date:(NSDate *)date xValue:(CGFloat)xValue yValue:(CGFloat)yValue
{
	if (nil == date || ![date isKindOfClass:[NSDate class]])
	{
		return;
	}
	CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));
	CGFloat fontSize = tiny;
	NSDictionary *attributes = @{ NSFontAttributeName:[UIFont fontWithName:kDefaultFont size:fontSize] };
	NSString *formattedDateString = [shortDate() stringFromDate:date];
	NSAttributedString *string = [[NSAttributedString alloc] initWithString:formattedDateString attributes:attributes];
	CTLineRef displayLine = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)string);
	CGContextSetTextPosition(context, xValue, yValue);
	CTLineDraw(displayLine, context);
	CFRelease(displayLine);
}

- (void)drawText:(NSString *)text
         context:(CGContextRef)context
          xValue:(CGFloat)xValue
          yValue:(CGFloat)yValue
          colour:(UIColor *)colour
{
	CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));
	CGFloat fontSize = tiny;
	NSDictionary *attributes = @{ NSFontAttributeName:[UIFont fontWithName:kDefaultFont size:fontSize] };
	NSAttributedString *string = [[NSAttributedString alloc] initWithString:text attributes:attributes];
	CTLineRef displayLine = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)string);
	CGContextSetTextPosition(context, xValue, yValue);
	CTLineDraw(displayLine, context);
	CFRelease(displayLine);
}

@end
