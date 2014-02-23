//
//  ResultsView-iPad.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 23/02/2014.
//
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "Results.h"

@interface ResultsView_iPad : UIView
+ (ResultsView_iPad *)viewForResults:(Results *)results
                           resultsType:(ResultsType)resultsType
                                 frame:(CGRect)frame;
@end
