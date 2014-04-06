//
//  CustomToolbar.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 08/02/2014.
//
//

#import <UIKit/UIKit.h>
#import "PWESToolbarDelegate.h"
@interface CustomToolbar : UIToolbar
@property (nonatomic, weak) id <PWESToolbarDelegate> customToolbarDelegate;
@end
