//
//  CoreCSVWriter.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 10/05/2014.
//
//

#import <Foundation/Foundation.h>

@interface CoreCSVWriter : NSObject
+ (id)sharedInstance;
- (void)writeWithCompletionBlock:(iStayHealthyXMLBlock)completionBlock;
@end
