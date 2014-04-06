//
//  PWESPopoverDelegate.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 06/04/2014.
//
//

#import <Foundation/Foundation.h>

@protocol PWESPopoverDelegate <NSObject>
- (void)hidePopover;
- (void)presentPopoverWithController:(UINavigationController *)controller
                            fromRect:(CGRect)frame;
- (void)presentPopoverWithController:(UINavigationController *)controller
                       fromBarButton:(UIBarButtonItem *)barButton;
@end
