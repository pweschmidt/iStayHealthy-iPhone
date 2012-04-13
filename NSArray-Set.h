//
//  NSArray-Set.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 04/01/2011.
//  Copyright 2011 __pweschmidt__. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 This useful snippet comes from 'More iPhone 3 Development' by D Mark and J LeMarche. See chapter 7: page200
 */

@interface NSArray(Set)
+ (id)arrayByOrderingSet:(NSSet *)set byKey:(NSString *)key ascending:(BOOL)ascending reverseOrder:(BOOL)reverse;
@end
