//
//  ChartEvents.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 17/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ChartEvents : NSObject {
    NSMutableArray *allChartEvents;
}
@property (nonatomic, retain) NSMutableArray *allChartEvents;
- (void)loadResult:(NSArray *)results;
- (void)loadMedication:(NSArray *)medications;
- (void)loadMissedMedication:(NSArray *)missedMedications;
- (void)sortEventsAscending:(BOOL)ascending;
@end

@interface ChartEvent : NSObject {
    NSDate      *date;   
    NSNumber    *CD4Count;
    NSNumber    *CD4Percent;
    NSNumber    *ViralLoad;
    NSString    *medicationName;
    NSString    *missedName;        
}
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSNumber *CD4Count;
@property (nonatomic, retain) NSNumber *CD4Percent;
@property (nonatomic, retain) NSNumber *ViralLoad;
@property (nonatomic, retain) NSString *missedName;
@property (nonatomic, retain) NSString *medicationName;

@end
