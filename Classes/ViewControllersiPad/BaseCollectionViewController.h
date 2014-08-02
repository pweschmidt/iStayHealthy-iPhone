//
//  BaseCollectionViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/11/2013.
//
//

#import <UIKit/UIKit.h>
#import "PWESPopoverDelegate.h"
#import "PWESToolbarDelegate.h"
#import <MessageUI/MessageUI.h>
@class CustomToolbar;

@interface BaseCollectionViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, PWESPopoverDelegate, PWESToolbarDelegate, UIPopoverControllerDelegate, MFMailComposeViewControllerDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *collectionViewLayout;
@property (nonatomic, strong) CustomToolbar *toolbar;
@property (nonatomic, strong) UIBarButtonItem *hamburgerMenuBarButton;
@property (nonatomic, strong) UIBarButtonItem *addMenuBarButton;
@property (nonatomic, strong) UIPopoverController *customPopoverController;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UILabel *activityLabel;
@property (nonatomic, assign) BOOL hasNavHeader;
- (void)reloadSQLData:(NSNotification *)notification;
- (void)startAnimation:(NSNotification *)notification;
- (void)stopAnimation:(NSNotification *)notification;
- (void)handleError:(NSNotification *)notification;
- (void)handleStoreChanged:(NSNotification *)notification;
- (void)setTitleViewWithTitle:(NSString *)titleString;
- (void)addButtonPressed:(id)sender;
- (void)animateViewWithText:(NSString *)text;
- (void)stopAnimateView;
- (void)createIndicatorsInView:(UIView *)collectionView;
@end
