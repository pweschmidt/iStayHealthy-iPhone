//
//  PreviousMedViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 08/09/2012.
//
//

#import <UIKit/UIKit.h>
@class iStayHealthyRecord;

@interface PreviousMedViewController : UITableViewController 
@property (nonatomic, strong) iStayHealthyRecord * record;
@property (nonatomic, strong) NSMutableArray * allPreviousMedications;
- (IBAction)removeEntry:(id)sender;
- (id)initWithRecord:(iStayHealthyRecord *)masterrecord;
@end
