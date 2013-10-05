//
//  Procedures+Handling.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 11/08/2013.
//
//

#import "Procedures.h"

@interface Procedures (Handling)
- (void)importFromDictionary:(NSDictionary *)attributes;
- (NSString *)xmlString;
- (void)addValueString:(NSString *)valueString type:(NSString *)type;
- (NSString *)valueStringForType:(NSString *)type;
@end
