//
//  ClinicAddressCell.h
//  iStayHealthy
//
//  Created by peterschmidt on 09/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ClinicAddressCellDelegate;

@interface ClinicAddressCell : UITableViewCell<UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UILabel *title;
@property (nonatomic, strong) IBOutlet UITextField *valueField;
@property (nonatomic, weak) id<ClinicAddressCellDelegate> clinicAddressCellDelegate;
- (void)setDelegate:(id)viewControllerDelegate;
@end
@protocol ClinicAddressCellDelegate <NSObject>
- (void)setValueString:(NSString *)valueString withTag:(int)tag;
- (void)setUnitString:(NSString *)unitString;
@end