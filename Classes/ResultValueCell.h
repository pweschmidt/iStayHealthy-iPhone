//
//  ResultValueCell.h
//  iStayHealthy
//
//  Created by peterschmidt on 05/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ResultValueCellDelegate;

@interface ResultValueCell : UITableViewCell<UITextFieldDelegate>{
    IBOutlet UILabel *title;
    IBOutlet UITextField *valueField;
    id<ResultValueCellDelegate>_delegate;
}
@property (nonatomic, retain) IBOutlet UILabel *title;
@property (nonatomic, retain) IBOutlet UITextField *valueField;
@property (nonatomic, assign) id<ResultValueCellDelegate>_delegate;
- (void)setDelegate:(id)viewControllerDelegate;
@end

@protocol ResultValueCellDelegate <NSObject>

- (void)setValueString:(NSString *)valueString withTag:(int)tag;

@end
