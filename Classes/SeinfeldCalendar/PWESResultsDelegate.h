//
//  PWESResultsDelegate.h
//  SeinfeldCalendarWithLayers
//
//  Created by Peter Schmidt on 25/04/2014.
//  Copyright (c) 2014 Peter Schmidt. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SeinfeldCalendarEntry;

@protocol PWESResultsDelegate <NSObject>
- (void)updateCalendar;
- (void)finishCalendar;
@end
