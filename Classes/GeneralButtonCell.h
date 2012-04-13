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
    id<GeneralButtonCellDelegate>_delegate;
}
@property (nonatomic, retain) IBOutlet UIButton *medButton;
@property (nonatomic, retain) IBOutlet UIButton *procButton;
@property (nonatomic, retain) IBOutlet UIButton *clinicButton;
@property (nonatomic, assign) id<GeneralButtonCellDelegate>_delegate;
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