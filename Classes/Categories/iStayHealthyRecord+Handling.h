//
//  iStayHealthyRecord+Handling.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 11/08/2013.
//
//

#import "iStayHealthyRecord.h"

@interface iStayHealthyRecord (Handling)
- (void)importFromDictionary:(NSDictionary *)attributes;
- (NSString *)xmlString;
@end
