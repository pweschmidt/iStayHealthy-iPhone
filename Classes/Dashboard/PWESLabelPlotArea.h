//
//  PWESLabelPlotArea.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 25/05/2014.
//
//

#import "PWESPlotArea.h"

@interface PWESLabelPlotArea : PWESPlotArea
- (id)initWithFrame:(CGRect)frame
              label:(NSString *)label
             colour:(UIColor *)colour;

- (void)plotLabel;
@end
