//
//  NSString+Extras.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 24/11/2013.
//
//

#import <Foundation/Foundation.h>

@interface NSString (Extras)
- (NSString *)valueStringForType:(NSString *)type value:(NSNumber *)value;
- (NSString *)valueStringForType:(NSString *)type valueAsFloat:(CGFloat)valueAsFloat;
@end
