//
//  PWESDashboardSummaryView.m
//  HealthCharts
//
//  Created by Peter Schmidt on 20/07/2013.
//  Copyright (c) 2013 Peter Schmidt. All rights reserved.
//

#import "PWESDashboardSummaryView.h"
#import "PWESResultsSummaryView.h"
#import "PWESDataTuple.h"

@implementation PWESDashboardSummaryView

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		// Initialization code
	}
	return self;
}

+ (PWESDashboardSummaryView *)summaryViewWithFrame:(CGRect)frame
                                            nTuple:(PWESDataNTuple *)nTuple
                                             types:(PWESResultsTypes *)types
{
	PWESDashboardSummaryView *summaryView = [[PWESDashboardSummaryView alloc] initWithFrame:frame];
	[summaryView buildSummaryViewForNTuple:nTuple types:types];
	return summaryView;
}

- (void)buildSummaryViewForNTuple:(PWESDataNTuple *)nTuple
                            types:(PWESResultsTypes *)types
{
	if (nil == nTuple  || nil == types)
	{
		return;
	}
	CGFloat componentWidth = self.bounds.size.width;
//	CGFloat componentHeight = self.bounds.size.height;
//	if (types.isDualType)
//	{
//		componentHeight = componentHeight / 2;
//	}
	CGFloat xOrigin = self.bounds.origin.x;
	CGFloat yOrigin = self.bounds.origin.y;
	PWESDataTuple *tuple = [nTuple resultsTupleForType:types.mainType];
	CGRect frame = CGRectMake(xOrigin, yOrigin, componentWidth, 40);
	PWESResultsSummaryView *resultsView = [PWESResultsSummaryView
	                                       resultsSummaryViewWithFrame:frame
	                                                         dataTuple:tuple];
	[self addSubview:resultsView];
	if (types.isDualType)
	{
		PWESDataTuple *secondtuple = [nTuple resultsTupleForType:types.secondaryType];
		CGRect frame = CGRectMake(xOrigin, yOrigin + 30, componentWidth, 20);
		PWESResultsSummaryView *secondResultsView = [PWESResultsSummaryView
		                                             resultsSummaryViewWithFrame:frame
		                                                               dataTuple:secondtuple];
		[self addSubview:secondResultsView];
	}
}

@end
