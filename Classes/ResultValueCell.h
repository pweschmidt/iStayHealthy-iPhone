//
//  ResultValueCell.h
//  iStayHealthy
//
//  Created by peterschmidt on 05/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define INTEGERINPUT 1
#define FLOATINPUT 2
#define BLOODPRESSUREINPUT 3

@protocol ResultValueCellDelegate;

@interface ResultValueCell : UITableViewCell<UITextFieldDelegate>{
    id<ResultValueCellDelegate> resultValueDelegate;
}
@property (nonatomic, weak) IBOutlet UILabel *inputTitle;
@property (nonatomic, weak) IBOutlet UITextField *inputValueField;
@property (nonatomic, weak) id<ResultValueCellDelegate> resultValueDelegate;
@property NSInteger inputValueKind;
- (void)setDelegate:(id)viewControllerDelegate;
@end

@protocol ResultValueCellDelegate <NSObject>

- (void)setValueString:(NSString *)valueString withTag:(int)tag;

@end
