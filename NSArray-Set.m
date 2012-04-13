//
//  NSArray-Set.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 04/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSArray-Set.h"


@implementation NSArray(Set)
+ (id)arrayByOrderingSet:(NSSet *)set byKey:(NSString *)key ascending:(BOOL)ascending reverseOrder:(BOOL)reverse{
		
	NSMutableArray *sortedArray = [NSMutableArray arrayWithCapacity:[set count]];
	for (id oneObject in set) {
		[sortedArray addObject:oneObject];
	}
	
	NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:ascending];
	if (reverse) {
		[sortedArray sortUsingDescriptors:[NSArray arrayWithObject:[descriptor reversedSortDescriptor]]];
	}
	else {
		[sortedArray sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];
	}

	[descriptor release];
	return sortedArray;
}

@end
