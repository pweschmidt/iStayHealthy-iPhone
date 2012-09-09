//
//  PressureCell.h
//  iStayHealthy
//
//  Created by peterschmidt on 22/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PressureCellDelegate;

@interface PressureCell : UITableViewCell <UITextFieldDelegate>
@property (nonatomic, weak) IBOutlet UILabel *pressureLabel;
@property (nonatomic, weak) IBOutlet UITextField *systoleField;
@property (nonatomic, weak) IBOutlet UITextField *diastoleField;
@property (nonatomic, weak) id<PressureCellDelegate> pressureDelegate;
@property (nonatomic, weak) IBOutlet UIView *colourCodeView;
- (void)setDelegate:(id)viewControllerDelegate;
@end

@protocol PressureCellDelegate <NSObject>

- (void)setSystole:(NSString *)systole diastole:(NSString *)diastole;
- (void)setValue:(NSString *)value tag:(NSInteger)tag;
@end