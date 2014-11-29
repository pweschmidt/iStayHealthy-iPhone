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

/**
   To illustrate how this works. Here is the basic structure of a messed up XML doc

   <XMLPreamble>
   <iStayHealthy ...>
   <XMLPreamble>
   <iStayHealthy ...>
   <XMLPreamble>
   <iStayHealthy ...>
   <XMLPreamble>
   <iStayHealthy ...>
   <Results..>
   </iStayHealthy>
   <Results...>
   </iStayHealthy>
   <Results...>
   </iStayHealthy>
   <Results...>

   </iStayHealthy>

   1. we first split by </iStayHealthy>. This will give at least 1 entry: one before (maybe 0) and possibly one after. The last will be empty if it is the last. From this array we take the first entry - as this will contain the full data set.
   2. we then need to get rid of the duplicated XML preambles and <iStayHealthy opening tags. We do this by splitting the resulting string by XMLPreamble components.
   3. again we get an array of at least 1 entry. We then run through the array
    - if the array has no duplicates, then we simply take the first component
    - otherwise we run through the array and check the length of the componentised string. The larger one will contain the full data set including the iStayHealthy opening statement.
   4. we then build the string by starting with the Preamble and adding the closing XML statement at the end


 */
+ (NSString *)correctedStringFromString:(NSString *)xmlString;
@end
