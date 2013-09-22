//
//  ResultsView_iPhone.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 22/09/2013.
//
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "Results.h"

@interface ResultsView_iPhone : UIView
+ (ResultsView_iPhone *)viewForResults:(Results *)results
                           resultsType:(ResultsType)resultsType
                                 frame:(CGRect)frame;
@end
