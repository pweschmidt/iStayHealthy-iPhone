//
//  PreviousMedViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 08/09/2012.
//
//

#import <UIKit/UIKit.h>

@interface PreviousMedViewController : UITableViewController 
@property (nonatomic, strong) NSMutableArray * allPreviousMedications;
- (IBAction)removeEntry:(id)sender;
- (id)initWithContext:(NSManagedObjectContext *)context;
- (void)reloadData:(NSNotification*)note;
@end
