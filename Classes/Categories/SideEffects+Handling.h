//
//  SideEffects+Handling.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 11/08/2013.
//
//

#import "SideEffects.h"
#import "NSManagedObject+Handling.h"

@interface SideEffects (Handling)
- (void)importFromDictionary:(NSDictionary *)attributes;
- (NSDictionary *)dictionaryForAttributes;
- (BOOL)isEqualToDictionary:(NSDictionary *)attributes;
@end
