//
//  PWESPlotAreaDelegate.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 19/05/2014.
//
//

#import <Foundation/Foundation.h>

@class PWESDataTuple;

@protocol PWESPlotAreaDelegate <NSObject>
- (void)configureBeforePlottingTuple:(PWESDataTuple *)tuple tupleLength:(NSUInteger)tupleLength;
@end
