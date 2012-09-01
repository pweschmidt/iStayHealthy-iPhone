//
//  ResultsAnalysis.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 29/08/2012.
//
//

#import <Foundation/Foundation.h>

@interface ResultsAnalysis : NSObject
@property (nonatomic, strong) NSMutableArray *results;
- (id)initWithResults:(NSArray *)allResults;

- (NSDictionary *)resultsForValue:(NSString *)value;
@end
