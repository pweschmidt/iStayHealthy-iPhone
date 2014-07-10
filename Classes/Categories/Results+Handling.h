//
//  Results+Handling.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 11/08/2013.
//
//

#import "Results.h"
#import "NSManagedObject+Handling.h"

@interface Results (Handling)
- (void)importFromDictionary:(NSDictionary *)attributes;
- (BOOL)isEqualToDictionary:(NSDictionary *)attributes;
- (void)addValueString:(NSString *)valueString type:(NSString *)type;
- (NSString *)valueStringForType:(NSString *)type;
@end
