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

- (void)writeWithCompletionBlock:(iStayHealthyXMLBlock)completionBlock;

@end
