//
//  Contacts+Handling.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 11/08/2013.
//
//

#import "Contacts.h"
#import "NSManagedObject+Handling.h"

@interface Contacts (Handling)
- (void)importFromDictionary:(NSDictionary *)attributes;
- (void)addValueString:(NSString *)valueString type:(NSString *)type;
- (NSString *)valueStringForType:(NSString *)type;
@end
