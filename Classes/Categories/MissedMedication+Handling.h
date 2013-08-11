//
//  MissedMedication+Handling.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 11/08/2013.
//
//

#import "MissedMedication.h"

@interface MissedMedication (Handling)
- (void)importFromDictionary:(NSDictionary *)attributes;
- (NSString *)xmlString;
@end
