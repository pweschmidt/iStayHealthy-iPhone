//
//  PWESValueRange.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 23/11/2013.
//
//

#import <Foundation/Foundation.h>

@class PWESDataTuple;

@interface PWESValueRange : NSObject
@property (nonatomic, strong, readonly) NSNumber *minValue;
@property (nonatomic, strong, readonly) NSNumber *maxValue;
@property (nonatomic, assign, readonly) CGFloat tickDeltaValue;
@property (nonatomic, strong, readonly) NSString *type;

+ (PWESValueRange *)valueRangeForDataTuple:(PWESDataTuple *)tuple ticks:(CGFloat)ticks;
@end
