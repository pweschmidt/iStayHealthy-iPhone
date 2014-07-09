//
//  CoreXMLReader.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 10/08/2013.
//
//

#import <Foundation/Foundation.h>

@interface CoreXMLReader : NSObject <NSXMLParserDelegate>
+ (id)sharedInstance;
- (void)parseXMLData:(NSData *)xmlData completionBlock:(iStayHealthySuccessBlock)completionBlock;
@end
