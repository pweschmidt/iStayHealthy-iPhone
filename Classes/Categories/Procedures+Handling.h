//
//  Procedures+Handling.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 11/08/2013.
//
//

#import "Procedures.h"
#import "NSManagedObject+Handling.h"
#import "Constants.h"

@interface Procedures (Handling)
- (void)importFromDictionary:(NSDictionary *)attributes;
- (BOOL)isEqualToDictionary:(NSDictionary *)attributes;
- (void)addValueString:(NSString *)valueString type:(NSString *)type;
- (NSString *)valueStringForType:(NSString *)type;
@end
