//
//  CoreXMLReader.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 10/08/2013.
//
//

#import <Foundation/Foundation.h>

@interface CoreXMLReader : NSObject <NSXMLParserDelegate>
/**
   checks if an XML file has actual content
   @param filePath
 */
- (BOOL)hasContentForXMLWithPath:(NSString *)filePath;

/**
   parse the actual XML data
   @param xmlData
   @param completionBlock
 */
- (void)parseXMLData:(NSData *)xmlData
     completionBlock:(iStayHealthySuccessBlock)completionBlock;
@end
