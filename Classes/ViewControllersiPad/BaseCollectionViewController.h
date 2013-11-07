//
//  BaseCollectionViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/11/2013.
//
//

#import <UIKit/UIKit.h>

@interface BaseCollectionViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *collectionViewLayout;
- (void)removeSQLEntry;
@end
