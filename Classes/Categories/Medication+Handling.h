//
//  Medication+Handling.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 11/08/2013.
//
//

#import "Medication.h"
#import "NSManagedObject+Handling.h"

@interface Medication (Handling)
- (void)importFromDictionary:(NSDictionary *)attributes;
@end
