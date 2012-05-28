//
//  GeneralButtonCell.h
//  iStayHealthy
//
//  Created by peterschmidt on 06/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GeneralButtonCellDelegate;

@interface GeneralButtonCell : UITableViewCell{
    IBOutlet UIButton *medButton;
    IBOutlet UIButton *procButton;
    IBOutlet UIButton *clinicButton;
    id<GeneralButtonCellDelegate>__unsafe_unretained _delegate;
}
@property (nonatomic, strong) IBOutlet UIButton *medButton;
@property (nonatomic, strong) IBOutlet UIButton *procButton;
@property (nonatomic, strong) IBOutlet UIButton *clinicButton;
@property (nonatomic, unsafe_unretained) id<GeneralButtonCellDelegate>_delegate;
- (void)setDelegate:(id)viewControllerDelegate;
- (IBAction)selectMed:(id)sender;
- (IBAction)selectProcedure:(id)sender;
- (IBAction)selectClinic:(id)sender;
@end

@protocol GeneralButtonCellDelegate <NSObject>

- (void)loadOtherMedicationDetailViewController;
- (void)loadProcedureAddViewController;
- (void)loadClinicAddViewController;

@end