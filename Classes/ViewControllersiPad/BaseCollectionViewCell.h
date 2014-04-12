//
//  BaseCollectionViewCell.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/11/2013.
//
//

#import <UIKit/UIKit.h>

@interface BaseCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) NSManagedObject *managedObject;
@property (nonatomic, strong, readonly) UIView *titleView;
@property (nonatomic, strong, readonly) UIView *labelContentView;

- (void)clear;
- (void)addDateToTitle:(NSDate *)date;
- (void)addTitle:(NSString *)title;
- (void)addLabelToContentView:(UILabel *)label;
@end
