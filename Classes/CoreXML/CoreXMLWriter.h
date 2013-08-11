//
//  CoreXMLWriter.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 11/08/2013.
//
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface CoreXMLWriter : NSObject
+ (id) sharedInstance;
- (void)writeXMLWithCompletionBlock:(iStayHealthySuccessBlock)completionBlock;
@end
