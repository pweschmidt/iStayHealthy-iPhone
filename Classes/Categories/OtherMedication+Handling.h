//
//  OtherMedication+Handling.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 11/08/2013.
//
//

#import "OtherMedication.h"

@interface OtherMedication (Handling)
- (void)importFromDictionary:(NSDictionary *)attributes;
- (NSString *)xmlString;
- (void)addValueString:(NSString *)valueString type:(NSString *)type;
- (NSString *)valueStringForType:(NSString *)type;
@end
