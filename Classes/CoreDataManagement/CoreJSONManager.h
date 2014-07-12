//
//  CoreJSONManager.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 12/07/2014.
//
//

#import <Foundation/Foundation.h>

@interface CoreJSONManager : NSObject
+ (id)sharedInstance;
- (void)writeCoreDataToJSONWithCompletionBlock:(iStayHealthyJSONDataBlock)completionBlock;
- (void)parseCoreDataFromJSONWithCompletionBlock:(iStayHealthyJSONDictionaryBlock)completionBlock;
@end
