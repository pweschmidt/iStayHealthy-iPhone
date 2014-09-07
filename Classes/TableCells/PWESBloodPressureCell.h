//
//  PWESBloodPressureCell.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 05/09/2014.
//
//

#import <UIKit/UIKit.h>
#import "PWESCustomTextfieldCell.h"

@interface PWESBloodPressureCell : PWESCustomTextfieldCell
//@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextField *systoleField;
@property (nonatomic, strong) UITextField *diastoleField;
@property (nonatomic, strong) UIView *additionalView;
@property (nonatomic, assign) UIKeyboardType adjustedKeyboardType;

- (void)createContentWithTitle:(NSString *)title
             textFieldDelegate:(id <UITextFieldDelegate> )textFieldDelegate
                  contentFrame:(CGRect)contentFrame;
//- (void)clear;
//- (void)partialShade;
//- (void)shade;
//- (void)unshade;
//- (void)adjustCellWidth:(CGFloat)newWidth;

@end
