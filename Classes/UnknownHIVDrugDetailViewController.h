//
//  UnknownHIVDrugDetailViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 16/04/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UnknownDrugDelegate;

@interface UnknownHIVDrugDetailViewController : UITableViewController {
	id<UnknownDrugDelegate> delegate;
    
}
@property (nonatomic, assign) id<UnknownDrugDelegate> delegate;
@end
@protocol UnknownDrugDelegate <NSObject>

- (void)setDrugName:(NSString *)drugName;
- (void)setDrugForm:(NSString *)drugForm;
- (void)setDrugCommercialName:(NSString *)drugCommercialName;

@end
