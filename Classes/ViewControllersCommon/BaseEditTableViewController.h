//
//  BaseEditTableViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/09/2013.
//
//

#import <UIKit/UIKit.h>
#import "GeneralSettings.h"
#import "Constants.h"

@interface BaseEditTableViewController : UITableViewController <UITextFieldDelegate>
@property (nonatomic, strong) NSMutableDictionary * contentViewsDictionary;
@property (nonatomic, strong) NSMutableDictionary * textViews;
@property (nonatomic, assign) BOOL isEditMode;
@property (nonatomic, strong) NSManagedObject * managedObject;

- (id)initWithStyle:(UITableViewStyle)style
      managedObject:(NSManagedObject *)managedObject
  hasNumericalInput:(BOOL)hasNumericalInput;

- (void)configureTableCell:(UITableViewCell *)cell
                     title:(NSString *)title
                 indexPath:(NSIndexPath *)indexPath;

- (void)configureDateCell:(UITableViewCell *)cell
                indexPath:(NSIndexPath *)indexPath;

@end
