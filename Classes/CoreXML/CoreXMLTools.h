//
//  CoreXMLTools.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 03/08/2014.
//
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface CoreXMLTools : NSObject
/**
   Sometimes Dropbox can't merge XML strings. In this case we need to clean up the string
   Most likely, there are duplicate entries.
 */
+ (NSString *)cleanedXMLString:(NSString *)string error:(NSError **)error;


/**
   validation is based on 3 steps
   - check if the string is not nil and not of length 0
   - check if the string contains the XML preamble and at least the open/close iStayHealthyRecord element
   - check that both preamble and iStayHealthyRecord elements only appear once
 */
+ (BOOL)validateXMLString:(NSString *)xmlString error:(NSError **)error;
@end
