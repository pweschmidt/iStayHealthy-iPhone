//
//  CustomToolbar.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 08/02/2014.
//
//

#import <UIKit/UIKit.h>
#import "PWESToolbarDelegate.h"
// @interface CustomToolbar : UIToolbar

@interface CustomToolbar : NSObject
@property (nonatomic, strong) NSArray *customItems;

- (instancetype)initWithToolbarManager:(id<PWESToolbarDelegate>)toolbarManager
                  presentingController:(UIViewController *)controller;
@end
