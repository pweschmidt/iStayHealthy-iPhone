//
//  ClinicsDetailViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 01/09/2012.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "ClinicAddressCell.h"

@class Contacts;

@interface ClinicsDetailViewController : UITableViewController <ClinicAddressCellDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) Contacts *contacts;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *idString;
@property (nonatomic, strong) NSString *www;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *number;
@property (nonatomic, strong) NSString *emergencynumber;

- (void)startEmailMessageView;
- (void)loadClinicWebview;
- (IBAction) showAlertView:			(id) sender;
- (void)removeSQLEntry;
- (IBAction) save:                  (id) sender;
- (IBAction) cancel:				(id) sender;
- (id)initWithContext:(NSManagedObjectContext *)context;
- (id)initWithContacts:(Contacts *)contacts;

@end
