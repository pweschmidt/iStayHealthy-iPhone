//
//  Medication+Handling.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 11/08/2013.
//
//

#import "Medication.h"

@interface Medication (Handling)
- (void)importFromDictionary:(NSDictionary *)attributes;
- (NSString *)xmlString;
@end
