//
//  EffectsSelectionTableViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 05/10/2013.
//
//

#import <UIKit/UIKit.h>
#import "EffectsSelectionDataSource.h"

@interface EffectsSelectionTableViewController : UITableViewController
@property (nonatomic, weak) id<EffectsSelectionDataSource> effectsDataSource;
@end
