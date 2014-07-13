//
//  PWESCustomTextfieldCell.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 05/04/2014.
//
//

#import <UIKit/UIKit.h>

@interface PWESCustomTextfieldCell : UITableViewCell
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextField *inputField;
@property (nonatomic, strong) UIView *additionalView;
@property (nonatomic, assign) UIKeyboardType adjustedKeyboardType;
- (void)createContentWithTitle:(NSString *)title
                  textFieldTag:(NSInteger)textFieldTag
             textFieldDelegate:(id <UITextFieldDelegate> )textFieldDelegate
             hasNumericalInput:(BOOL)hasNumericalInput
                  contentFrame:(CGRect)contentFrame;
- (void)clear;
- (void)partialShade;
- (void)shade;
- (void)unshade;
- (void)adjustCellWidth:(CGFloat)newWidth;
@end
