//
//  ViewWithActivityIndicator.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 29/09/2012.
//
//

#import <UIKit/UIKit.h>

@interface ViewWithActivityIndicator : UIView
@property (nonatomic, strong) UIActivityIndicatorView * activityIndicator;
- (void)stop;
@end
