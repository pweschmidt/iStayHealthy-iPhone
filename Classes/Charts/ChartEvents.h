//
//  ChartEvents.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 17/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ChartEvents : NSObject 
@property (nonatomic) NSMutableArray *allChartEvents;
- (void)loadResult:(NSArray *)results;
- (void)loadMedication:(NSArray *)medications;
- (void)loadMissedMedication:(NSArray *)missedMedications;
- (void)sortEventsAscending:(BOOL)ascending;
@end

@interface ChartEvent : NSObject 
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSNumber *CD4Count;
@property (nonatomic, strong) NSNumber *CD4Percent;
@property (nonatomic, strong) NSNumber *ViralLoad;
@property (nonatomic, strong) NSString *missedName;
@property (nonatomic, strong) NSString *medicationName;

@end
