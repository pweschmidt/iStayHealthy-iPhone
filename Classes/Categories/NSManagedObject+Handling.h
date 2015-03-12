//
//  NSManagedObject+Handling.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 11/08/2013.
//
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Handling)
/**
   gets the date from a value
 */
- (NSDate *)dateFromValue:(id)value;

/**
   gets a number from a value
 */
- (NSNumber *)numberFromValue:(id)value;

/**
   gets a string from a value
 */
- (NSString *)stringFromValue:(id)value;

/**
   generates an XML open element of syntax: <name ...
 */
- (NSString *)xmlOpenForElement:(NSString *)name;

/**
   generates an XML close element of syntax: </name ...
 */
- (NSString *)xmlClose:(NSString *)name;

/**
   generates an XML attributes for an element
 */
- (NSString *)xmlAttributeString:(NSString *)attributeName
                  attributeValue:(id)attributeValue;

/**
   returns the XML string representation for a core data class
 */
- (NSString *)xmlString;

/**
   returns the CSV string representation for a core data class
 */
- (NSString *)csvString;

/**
   returns the CSV header string
 */
- (NSString *)csvRowHeader;
@end
