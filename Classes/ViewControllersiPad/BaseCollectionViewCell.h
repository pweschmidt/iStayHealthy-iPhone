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

- (void)addDateToTitle:(NSDate *)date;
- (void)addTitle:(NSString *)title font:(UIFont *)font;
- (void)addLabelToContentView:(UILabel *)label;
@end
