//
//  SideEffects+Handling.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 11/08/2013.
//
//

#import "SideEffects.h"

@interface SideEffects (Handling)
- (void)importFromDictionary:(NSDictionary *)attributes;
- (NSString *)xmlString;
@end
