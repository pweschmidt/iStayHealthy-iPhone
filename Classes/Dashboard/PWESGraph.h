//
//  PWESGraph.h
//  HealthCharts
//
//  Created by Peter Schmidt on 12/07/2013.
//  Copyright (c) 2013 Peter Schmidt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PWESGraph : NSObject
@property (nonatomic, strong, readonly) NSArray * timeline;
@property (nonatomic, strong, readonly) NSDictionary * graph;
- (id)initWithRawResults:(NSArray *)results medications:(NSArray *)medications;
- (void)createGraphForPredicate:(NSPredicate *)predicate;
@end
