//
//  ResultsViewWithValue_iPhone.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/11/2014.
//
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "Results.h"

@interface ResultsViewWithValue_iPhone : UIView
+ (ResultsViewWithValue_iPhone *)viewForResults:(Results *)results
                                    resultsType:(NSString *)resultsType
                                          frame:(CGRect)frame;
@end
