//
//  DatabaseController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 23/06/2013.
//
//

#import <Foundation/Foundation.h>

@interface DatabaseController : NSObject
+ (id)sharedInstance;
- (void)setUpCoreDataStack;
@end
