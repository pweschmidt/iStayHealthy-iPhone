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
@class CustomToolbar;

@interface BaseCollectionViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, PWESPopoverDelegate, PWESToolbarDelegate, UIPopoverControllerDelegate /*, UICollectionViewDelegateFlowLayout */>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *collectionViewLayout;
@property (nonatomic, strong) CustomToolbar *toolbar;
@property (nonatomic, strong) UIBarButtonItem *hamburgerMenuBarButton;
@property (nonatomic, strong) UIBarButtonItem *addMenuBarButton;
@property (nonatomic, strong) UIPopoverController *customPopoverController;
- (void)setTitleViewWithTitle:(NSString *)titleString;
- (void)addButtonPressed:(id)sender;
@end
