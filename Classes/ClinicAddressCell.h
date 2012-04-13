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
    id<ClinicAddressCellDelegate> _delegate;
}
@property (nonatomic, retain) IBOutlet UILabel *title;
@property (nonatomic, retain) IBOutlet UITextField *valueField;
@property (nonatomic, assign) id<ClinicAddressCellDelegate> _delegate;
- (void)setDelegate:(id)viewControllerDelegate;
@end
@protocol ClinicAddressCellDelegate <NSObject>
- (void)setValueString:(NSString *)valueString withTag:(int)tag;
- (void)setUnitString:(NSString *)unitString;
@end