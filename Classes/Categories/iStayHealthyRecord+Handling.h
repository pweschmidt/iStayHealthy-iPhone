//
//  iStayHealthyRecord+Handling.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 11/08/2013.
//
//

#import "iStayHealthyRecord.h"
#import "NSManagedObject+Handling.h"

@interface iStayHealthyRecord (Handling)
- (void)importFromDictionary:(NSDictionary *)attributes;
- (NSDictionary *)dictionaryForAttributes;
- (BOOL)isEqualToDictionary:(NSDictionary *)attributes;
@end
