//
//  BasicViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 15/02/2013.
//
//

#import <UIKit/UIKit.h>
#import "StatusViewControllerLandscape.h"
#import <QuartzCore/QuartzCore.h>
@interface BasicViewController : UIViewController
@property (nonatomic, strong) IBOutlet UIView *headerView;
@property (nonatomic, strong) StatusViewControllerLandscape *landscapeController;
@property (nonatomic, strong) UIActivityIndicatorView * activityIndicator;
@property BOOL isShowingLandscape;
@property (nonatomic, strong) NSManagedObjectContext *context;
- (void)loadURL;
- (void)gotoPOZ;
- (void)orientationChanged:(NSNotification *)notification;
- (void)updateLandscapeView;
- (void)registerObservers;
- (void)setUpLandscapeController;
@end
