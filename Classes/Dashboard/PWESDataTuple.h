//
//  PWESDataTuple.h
//  HealthCharts
//
//  Created by Peter Schmidt on 27/07/2013.
//  Copyright (c) 2013 Peter Schmidt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PWESDataTuple : NSObject
@property (nonatomic, strong, readonly) NSArray *valueTuple;
@property (nonatomic, strong, readonly) NSArray *dateTuple;
@property (nonatomic, strong, readonly) NSString *type;

+(PWESDataTuple *)initWithValues:(NSArray *)values dates:(NSArray *)dates type:(NSString *)type;

- (NSUInteger)length;

- (BOOL)isEmpty;

- (id)valueForDate:(id)date;
@end
