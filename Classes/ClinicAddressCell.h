//
//  ClinicAddressCell.h
//  iStayHealthy
//
//  Created by peterschmidt on 09/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ClinicAddressCellDelegate;

@interface ClinicAddressCell : UITableViewCell<UITextFieldDelegate>{
    IBOutlet UILabel *title;
    IBOutlet UITextField *valueField;
    id<ClinicAddressCellDelegate> __unsafe_unretained _delegate;
}
@property (nonatomic, strong) IBOutlet UILabel *title;
@property (nonatomic, strong) IBOutlet UITextField *valueField;
@property (nonatomic, unsafe_unretained) id<ClinicAddressCellDelegate> _delegate;
- (void)setDelegate:(id)viewControllerDelegate;
@end
@protocol ClinicAddressCellDelegate <NSObject>
- (void)setValueString:(NSString *)valueString withTag:(int)tag;
- (void)setUnitString:(NSString *)unitString;
@end