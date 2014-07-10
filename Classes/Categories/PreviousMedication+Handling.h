//
//  PreviousMedication+Handling.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 11/08/2013.
//
//

#import "PreviousMedication.h"
#import "NSManagedObject+Handling.h"

@interface PreviousMedication (Handling)
- (void)importFromDictionary:(NSDictionary *)attributes;
- (BOOL)isEqualToDictionary:(NSDictionary *)attributes;
@end
