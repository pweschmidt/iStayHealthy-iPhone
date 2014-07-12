//
//  Wellness+Handling.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 11/08/2013.
//
//

#import "Wellness.h"
#import "NSManagedObject+Handling.h"

@interface Wellness (Handling)
- (void)importFromDictionary:(NSDictionary *)attributes;
- (NSDictionary *)dictionaryForAttributes;
- (BOOL)isEqualToDictionary:(NSDictionary *)attributes;
@end
