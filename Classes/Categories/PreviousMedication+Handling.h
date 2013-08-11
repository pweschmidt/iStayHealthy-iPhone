//
//  PreviousMedication+Handling.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 11/08/2013.
//
//

#import "PreviousMedication.h"

@interface PreviousMedication (Handling)
- (void)importFromDictionary:(NSDictionary *)attributes;
- (NSString *)xmlString;
@end
