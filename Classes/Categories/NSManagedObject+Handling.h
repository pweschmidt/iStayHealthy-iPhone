//
//  NSManagedObject+Handling.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 11/08/2013.
//
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Handling)
- (NSDate *)dateFromValue:(id)value;
- (NSNumber *)numberFromValue:(id)value;
- (NSString *)stringFromValue:(id)value;
- (NSString *)xmlOpenForElement:(NSString *)name;
- (NSString *)xmlClose:(NSString *)name;
- (NSString *)xmlAttributeString:(NSString *)attributeName
                  attributeValue:(id)attributeValue;
@end
