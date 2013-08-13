//
//  Results+Handling.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 11/08/2013.
//
//

#import "Results.h"

@interface Results (Handling)
- (void)importFromDictionary:(NSDictionary *)attributes;
- (NSString *)xmlString;
- (void)addValueString:(NSString *)valueString type:(NSString *)type;
@end
