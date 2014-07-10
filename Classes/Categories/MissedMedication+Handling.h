//
//  MissedMedication+Handling.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 11/08/2013.
//
//

#import "MissedMedication.h"
#import "NSManagedObject+Handling.h"

@interface MissedMedication (Handling)
- (void)importFromDictionary:(NSDictionary *)attributes;
- (BOOL)isEqualToDictionary:(NSDictionary *)attributes;
- (NSString *)xmlString;
@end
