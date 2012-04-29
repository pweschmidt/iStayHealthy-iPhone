//
//  SwitcherCell.h
//  iStayHealthy
//
//  Created by peterschmidt on 11/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SwitcherCellProtocol;

@interface SwitcherCell : UITableViewCell{
    IBOutlet UILabel *label;
    IBOutlet UISwitch *switcher;
    id<SwitcherCellProtocol>_delegate;
}
@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, retain) IBOutlet UISwitch *switcher;
@property (nonatomic, assign) id<SwitcherCellProtocol>_delegate;
- (void)setDelegate:(id)viewControllerDelegate;
- (IBAction)valueChanged:(id)sender;
@end

@protocol SwitcherCellProtocol <NSObject>
- (void)setMissed:(BOOL)isOn; 
@end