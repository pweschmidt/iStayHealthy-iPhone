//
//  ClinicsDetailViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 01/09/2012.
//
//

#import "ClinicsDetailViewController.h"
#import "iStayHealthyRecord.h"
#import "Utilities.h"
#import "Contacts.h"
#import "GradientButton.h"
#import "GeneralSettings.h"
#import "ChartSettings.h"
#import "WebViewController.h"

@interface ClinicsDetailViewController ()
@property BOOL isEdit;
@property NSUInteger buttonCount;
- (void)callNumber;
- (void)callEmergencyNumber;
@end

@implementation ClinicsDetailViewController
@synthesize isEdit = _isEdit;
@synthesize record = _record;
@synthesize contacts = _contacts;
@synthesize name = _name;
@synthesize idString = _idString;
@synthesize www = _www;
@synthesize email = _email;
@synthesize number = _number;
@synthesize emergencynumber = _emergencynumber;
@synthesize buttonCount = _buttonCount;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        // Custom initialization
    }
    return self;
}
- (id)initWithRecord:(iStayHealthyRecord *)masterrecord
{
    self = [super initWithNibName:@"ClinicsDetailViewController" bundle:nil];
    if (nil != self)
    {
        self.record = masterrecord;
        self.name = @"";
        self.idString = @"";
        self.www = @"";
        self.emergencynumber = @"";
        self.number = @"";
        self.email = @"";
        self.isEdit = NO;
    }
    return self;
}

- (id)initWithContacts:(Contacts *)contacts masterRecord:(iStayHealthyRecord *)masterrecord
{
    self = [super initWithNibName:@"ClinicsDetailViewController" bundle:nil];
    if (nil != self)
    {
        self.record = masterrecord;
        self.contacts = contacts;
        self.isEdit = YES;
        self.name = self.contacts.ClinicName;
        self.idString = self.contacts.ClinicID;
        self.www = self.contacts.ClinicWebSite;
        self.email = self.contacts.ClinicEmailAddress;
        self.number = self.contacts.ClinicContactNumber;
        self.emergencynumber = self.contacts.EmergencyContactNumber;
        self.buttonCount = 4;
        if (nil == self.name)
        {
            self.name = @"";
        }
        if (nil == self.idString)
        {
            self.idString = @"";
        }
        if (nil == self.www)
        {
            self.www = @"";
            self.buttonCount = self.buttonCount - 1;
        }
        else if ([self.www isEqualToString:@""])
        {
            self.buttonCount = self.buttonCount - 1;
        }
        if (nil == self.email)
        {
            self.email = @"";
            self.buttonCount = self.buttonCount - 1;
        }
        else if ([self.email isEqualToString:@""])
        {
            self.buttonCount = self.buttonCount - 1;
        }
        if (nil == self.number)
        {
            self.number = @"";
            self.buttonCount = self.buttonCount - 1;
        }
        else if ([self.number isEqualToString:@""])
        {
            self.buttonCount = self.buttonCount - 1;
        }
        if (nil == self.emergencynumber)
        {
            self.emergencynumber = @"";
            self.buttonCount = self.buttonCount - 1;
        }
        else if ([self.emergencynumber isEqualToString:@""])
        {
            self.buttonCount = self.buttonCount - 1;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.isEdit)
    {
        if (nil != self.name)
        {
            self.navigationItem.title = self.name;
        }
        else
        {
            self.navigationItem.title = NSLocalizedString(@"Edit Clinic",nil);            
        }
    }
    else
    {
        self.navigationItem.title = NSLocalizedString(@"Add Clinic",nil);        
    }
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                             target:self action:@selector(cancel:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                              target:self action:@selector(save:)];
}

#if  defined(__IPHONE_5_1) || defined (__IPHONE_5_0)
- (void)viewDidUnload
{
    self.idString = nil;
    self.name = nil;
    self.www = nil;
    self.email = nil;
    self.emergencynumber = nil;
    
    [super viewDidUnload];
}
#endif

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 48.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.isEdit)
    {
        return 90;
    }
    else
    {
        return 10;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (self.isEdit)
    {
        return 90;
    }
    else
    {
        return 10;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (!self.isEdit)
    {
        return [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 10)];
    }
    
    CGRect headerFrame = CGRectMake(0, 0, tableView.bounds.size.width, 90);
    UIView *headerView = [[UIView alloc] initWithFrame:headerFrame];
    float buttonWidth = tableView.bounds.size.width/2 - 30;
    CGRect callFrame = CGRectMake(10, 4, buttonWidth, 37);
    CGRect emergencyFrame = CGRectMake(50 + buttonWidth, 4, buttonWidth, 37);
    CGRect emailFrame = CGRectMake(10, 45, buttonWidth, 37);
    CGRect wwwFrame = CGRectMake(50+buttonWidth, 45, buttonWidth, 37);
    
    GradientButton *callButton = [[GradientButton alloc] initWithFrame:callFrame
                                                                colour:Green
                                                                 title:NSLocalizedString(@"Call", @"Call")];
    [callButton addTarget:self
                   action:@selector(callNumber)
         forControlEvents:UIControlEventTouchUpInside];

    GradientButton *emergencyButton = [[GradientButton alloc] initWithFrame:emergencyFrame
                                                                     colour:Orange
                                                                      title:NSLocalizedString(@"Emergency", @"Call")];
    [emergencyButton addTarget:self
                        action:@selector(callEmergencyNumber)
              forControlEvents:UIControlEventTouchUpInside];

    GradientButton *emailButton = [[GradientButton alloc] initWithFrame:emailFrame colour:Green title:NSLocalizedString(@"Send email", @"Send email")];
    [emailButton addTarget:self
                    action:@selector(startEmailMessageView)
          forControlEvents:UIControlEventTouchUpInside];
    
    GradientButton *wwwButton = [[GradientButton alloc] initWithFrame:wwwFrame colour:Green title:NSLocalizedString(@"Go to Website", @"Go to Website")];
    [wwwButton addTarget:self
                  action:@selector(loadClinicWebview)
        forControlEvents:UIControlEventTouchUpInside];
    
    [headerView addSubview:callButton];
    [headerView addSubview:emergencyButton];
    [headerView addSubview:emailButton];
    [headerView addSubview:wwwButton];
    
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = nil;
    footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 10)];
    if (self.isEdit)
    {
        footerView.frame = CGRectMake(0, 0, tableView.bounds.size.width, 50);
        CGRect deleteFrame = CGRectMake(10, 10, tableView.bounds.size.width - 20 , 37);
        GradientButton *deleteButton = [[GradientButton alloc] initWithFrame:deleteFrame colour:Red title:NSLocalizedString(@"Delete", @"Delete")];
        [deleteButton addTarget:self action:@selector(showAlertView:) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:deleteButton];
    }
    
    return footerView;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"ClinicAddressCell";
    ClinicAddressCell *cell = (ClinicAddressCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (nil == cell)
    {
        NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"ClinicAddressCell"
                                                            owner:self
                                                          options:nil];
        for (id currentObject in cellObjects)
        {
            if ([currentObject isKindOfClass:[ClinicAddressCell class]])
            {
                cell = (ClinicAddressCell *)currentObject;
                break;
            }
        }
        [cell setDelegate:self];
    }
    int row = indexPath.row;
    switch (row)
    {
        case 0:
            cell.title.text = NSLocalizedString(@"Clinic", @"Clinic");
            if (self.isEdit && ![self.name isEqualToString:@""])
            {
                cell.valueField.text = self.name;
                cell.valueField.textColor = [UIColor blackColor];
            }
            else
            {
                cell.valueField.text = NSLocalizedString(@"Enter Name", @"Enter Name");
                cell.valueField.textColor = [UIColor lightGrayColor];
            }
            
            break;
        case 1:
            cell.title.text = NSLocalizedString(@"Clinic ID", @"Clinic ID");
            if (self.isEdit && ![self.idString isEqualToString:@""])
            {
                cell.valueField.text = self.idString;
                cell.valueField.textColor = [UIColor blackColor];
            }
            else
            {
                cell.valueField.text = NSLocalizedString(@"Your ID", @"Your ID");
                cell.valueField.textColor = [UIColor lightGrayColor];
            }
            break;
        case 2:
            cell.title.text = NSLocalizedString(@"Web", @"Web");
            cell.valueField.keyboardType = UIKeyboardTypeURL;
            if (self.isEdit && ![self.www isEqualToString:@""])
            {
                cell.valueField.text = self.www;
                cell.valueField.textColor = [UIColor blackColor];
            }
            else
            {
                cell.valueField.text = NSLocalizedString(@"http://www...", @"http://www...");
                cell.valueField.textColor = [UIColor lightGrayColor];
            }
            break;
        case 3:
            cell.title.text = NSLocalizedString(@"Email", @"Email");
            cell.valueField.keyboardType = UIKeyboardTypeEmailAddress;
            if (self.isEdit && ![self.email isEqualToString:@""])
            {
                cell.valueField.text = self.email;
                cell.valueField.textColor = [UIColor blackColor];
            }
            else
            {
                cell.valueField.text = NSLocalizedString(@"Clinic email", @"Clinic email");
                cell.valueField.textColor = [UIColor lightGrayColor];
            }
            break;
        case 4:
            cell.title.text = NSLocalizedString(@"Phone", @"Phone");
            cell.valueField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            if (self.isEdit && ![self.number isEqualToString:@""])
            {
                cell.valueField.text = self.number;
                cell.valueField.textColor = [UIColor blackColor];
            }
            else
            {
                cell.valueField.text = NSLocalizedString(@"Enter Number", @"Enter Number");
                cell.valueField.textColor = [UIColor lightGrayColor];
            }
            break;
        case 5:
            cell.title.text = NSLocalizedString(@"Emergency", @"Emergency");
            cell.valueField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            if (self.isEdit && ![self.emergencynumber isEqualToString:@""])
            {
                cell.valueField.text = self.number;
                cell.valueField.textColor = [UIColor blackColor];
            }
            else
            {
                cell.valueField.text = NSLocalizedString(@"Enter Number", @"Enter Number");
                cell.valueField.textColor = [UIColor lightGrayColor];
            }
            break;
    }
    [cell setTag:row];
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - private methods
- (IBAction) showAlertView:			(id) sender
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Delete?", @"Delete?") message:NSLocalizedString(@"Do you want to delete this entry?", @"Do you want to delete this entry?") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"Yes", @"Yes"), nil];
    
    [alert show];    
}

/**
 if user really wants to delete the entry call removeSQLEntry
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:NSLocalizedString(@"Yes", @"Yes")])
    {
        [self removeSQLEntry];
    }
}


- (void)removeSQLEntry
{
    [self.record removeContactsObject:self.contacts];
    NSManagedObjectContext *context = [self.contacts managedObjectContext];
    [context deleteObject:self.contacts];
    NSError *error = nil;
    if (![context save:&error])
    {
#ifdef APPDEBUG
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
        abort();
    }
    [self dismissModalViewControllerAnimated:YES];    
}

- (IBAction) save:                  (id) sender
{
    NSManagedObjectContext *context = nil;
    if (self.isEdit)
    {
        context = [self.contacts managedObjectContext];
        self.record.UID = [Utilities GUID];
        self.contacts.ClinicName = self.name;
        self.contacts.ClinicID = self.idString;
        self.contacts.ClinicWebSite = self.www;
        self.contacts.ClinicEmailAddress = self.email;
        self.contacts.ClinicContactNumber = self.number;
        self.contacts.EmergencyContactNumber = self.emergencynumber;
        self.contacts.UID = [Utilities GUID];
    }
    else
    {
        context = [self.record managedObjectContext];
        Contacts *contact = [NSEntityDescription insertNewObjectForEntityForName:@"Contacts" inManagedObjectContext:context];
        [self.record addContactsObject:contact];
        self.record.UID = [Utilities GUID];
        contact.ClinicName = self.name;
        contact.ClinicID = self.idString;
        contact.ClinicWebSite = self.www;
        contact.ClinicEmailAddress = self.email;
        contact.ClinicContactNumber = self.number;
        contact.EmergencyContactNumber = self.emergencynumber;
        contact.UID = [Utilities GUID];
    }
    NSError *error = nil;
    if (![context save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction) cancel:				(id) sender
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - ClinicAddressCellDelegate Protocol implementation
- (void)setValueString:(NSString *)valueString withTag:(int)tag
{
    switch (tag)
    {
        case 0:
            self.name = valueString;
            break;
        case 1:
            self.idString = valueString;
            break;
        case 2:
            self.www = valueString;
            break;
        case 3:
            self.email = valueString;
            break;
        case 4:
            self.number = valueString;
            break;
        case 5:
            self.emergencynumber = valueString;
            break;
    }
}

- (void)setUnitString:(NSString *)unitString{
    //do nothing unit is not needed for these types of cells
}

#pragma mark - messaging and email
- (void)startEmailMessageView
{
    if (![MFMailComposeViewController canSendMail])
    {
        return;
    }
    NSString *deviceType = [[UIDevice currentDevice]model];
    if ([deviceType hasSuffix:@"Simulator"])
    {
    }
    
    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
    mailController.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    NSArray *toRecipient = [NSArray arrayWithObjects:self.email, nil];
    mailController.mailComposeDelegate = self;
    [mailController setToRecipients:toRecipient];
    [mailController setSubject:@"Message from iStayHealthy..."];
    [self presentModalViewController:mailController animated:YES];
    
}


/**
 called when e-mail message is sent
 */
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    NSString *resultText = @"";
    switch (result)
    {
        case MFMailComposeResultCancelled:
        {
            break;
        }
        case MFMailComposeResultSent:
        {
            break;
        }
        case MFMailComposeResultFailed:
        {
            resultText = @"Result: failed";
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"iStayHealthy Email"
                                                                message:resultText delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
            break;
        }
        case MFMailComposeResultSaved:
        {
            break;
        }
    }
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark WebView
- (void)loadClinicWebview
{
    NSString *webURL = self.www;
    if (![self.www hasPrefix:@"http://"] && ![self.www hasPrefix:@"https://"])
    {
        webURL = [NSString stringWithFormat:@"http://%@",self.www];
    }
    
    
    WebViewController *webViewController = [[WebViewController alloc]initWithURLString:webURL withTitle:self.name];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webViewController];
    UINavigationBar *navigationBar = [navigationController navigationBar];
    navigationBar.tintColor = [UIColor blackColor];
    [self presentModalViewController:navigationController animated:YES];
}

- (void)callNumber
{
    UIApplication *app = [UIApplication sharedApplication];
    NSString *cleanedString = [[self.number componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789-+()"] invertedSet]] componentsJoinedByString:@""];
    NSString *escapedPhoneNumber = [cleanedString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *telURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", escapedPhoneNumber]];
    [app openURL:telURL];
    
}

- (void)callEmergencyNumber
{
    UIApplication *app = [UIApplication sharedApplication];
    NSString *cleanedString = [[self.emergencynumber componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789-+()"] invertedSet]] componentsJoinedByString:@""];
    NSString *escapedPhoneNumber = [cleanedString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *telURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", escapedPhoneNumber]];
    [app openURL:telURL];
    
}



@end
