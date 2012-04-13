//
//  GeneralMedicalTableViewController.m
//  iStayHealthy
//
//  Created by peterschmidt on 08/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GeneralMedicalTableViewController.h"
#import "iStayHealthyRecord.h"
#import "GeneralSettings.h"
#import "NSArray-Set.h"
#import "OtherMedicationDetailViewController.h"
#import "OtherMedicationChangeViewController.h"
#import "OtherMedication.h"
#import "Contacts.h"
#import "ClinicAddTableViewController.h"
#import "Procedures.h"
#import "ProcedureAddViewController.h"
#import "ProcedureChangeViewController.h"
#import "Utilities.h"
#import "ProcedureCell.h"
#import "ClinicCell.h"
#import "OtherMedCell.h"
#import "WebViewController.h"

@implementation GeneralMedicalTableViewController
@synthesize selectedContactRow;

/**
 dealloc
 */
- (void)dealloc {
    [super dealloc];
}



- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if (navBar) {
        CGRect pozFrame = CGRectMake(CGRectGetMinX(navBar.bounds) + 70.0, CGRectGetMinY(navBar.bounds)+7, 180, 29);
        UIButton *pozButton = [[[UIButton alloc]initWithFrame:pozFrame]autorelease];
        [pozButton setBackgroundColor:[UIColor clearColor]];
        [pozButton setImage:[UIImage imageNamed:@"generalnavbar.png"] forState:UIControlStateNormal];
        [pozButton addTarget:self action:@selector(gotoPOZ) forControlEvents:UIControlEventTouchUpInside];
        [navBar addSubview:pozButton];
    }
//	self.navigationItem.title = NSLocalizedString(@"General", @"General");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - actionsheet handling
- (void) showActionSheetForContact:(int)row{
    Contacts *contact = (Contacts *)[self.allContacts objectAtIndex:row];
    NSString *name = contact.ClinicName;    
    UIActionSheet *contactSheet = [[UIActionSheet alloc]initWithTitle:name delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:NSLocalizedString(@"Edit", @"Edit") otherButtonTitles:NSLocalizedString(@"Call", @"Call"), NSLocalizedString(@"Emergency", @"Emergency"), NSLocalizedString(@"Send email", @"Send email"), NSLocalizedString(@"Got to Website", @"Go to Website"), nil];
    contactSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    NSString *deviceTypes = [[UIDevice currentDevice]model];
    if (![deviceTypes hasPrefix:@"iPhone"] || [deviceTypes hasSuffix:@"Simulator"]) {
        [contactSheet dismissWithClickedButtonIndex:1 animated:YES];
        [contactSheet dismissWithClickedButtonIndex:2 animated:YES];
    }
    [contactSheet dismissWithClickedButtonIndex:contactSheet.cancelButtonIndex animated:YES];
    CGRect frame = CGRectMake(0, 0, 320, 480);
    [contactSheet showFromRect:frame inView:self.view animated:YES];
//    [contactSheet showInView:self.view];
    [contactSheet release];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    Contacts *contact = (Contacts *)[self.allContacts objectAtIndex:self.selectedContactRow];
    NSString *clinicNumber = contact.ClinicContactNumber;
    if ([clinicNumber isEqualToString:@""] && 1 == buttonIndex) {
        [actionSheet dismissWithClickedButtonIndex:1 animated:YES];
        return;
    }
    NSString *emergencyNumber = contact.EmergencyContactNumber;
    if ([emergencyNumber isEqualToString:@""] && 2 == buttonIndex) {
        [actionSheet dismissWithClickedButtonIndex:2 animated:YES];
        return;
    }
    NSString *email = contact.ClinicEmailAddress;
    if ([email isEqualToString:@""] && 3 == buttonIndex) {
        [actionSheet dismissWithClickedButtonIndex:3 animated:YES];
        return;
    }
    NSString *www = contact.ClinicWebSite;
    if ([www isEqualToString:@""] && 4 == buttonIndex) {
        [actionSheet dismissWithClickedButtonIndex:4 animated:YES];
        return;
    }
    
    
    switch (buttonIndex) {
        case 0:
            [self loadClinicChangeViewController];
            break;
        case 1:
            {
                NSString *phoneURL = [NSString stringWithFormat:@"tel://%@",clinicNumber];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneURL]];
            }
            break;
        case 2:
            {
                NSString *phoneURL = [NSString stringWithFormat:@"tel://%@",emergencyNumber];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneURL]];
            }
            break;
        case 3:
            {
                [self startEmailMessageView:email];
            }
            break;
        case 4:
            {
                [self loadClinicWebview:www withTitle:contact.ClinicName];
            }
            break;
        
    }
        
}

- (void)loadClinicWebview:(NSString *)url withTitle:(NSString *)navTitle{
    NSString *webURL = url;
    if (![url hasPrefix:@"http://"] && ![url hasPrefix:@"https://"]) {
        webURL = [NSString stringWithFormat:@"http://%@",url];
    }
    
    
    WebViewController *webViewController = [[WebViewController alloc]initWithURLString:webURL withTitle:navTitle];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webViewController];
    UINavigationBar *navigationBar = [navigationController navigationBar];
    navigationBar.tintColor = [UIColor blackColor];
    [self presentModalViewController:navigationController animated:YES];
    [webViewController release];
    [navigationController release];    
}



- (void)startEmailMessageView:(NSString *)emailAddress{
    if (![MFMailComposeViewController canSendMail]) {
        return;
    }
    NSString *deviceType = [[UIDevice currentDevice]model];
    if ([deviceType hasSuffix:@"Simulator"]) {
    }
    
    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
    mailController.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    NSArray *toRecipient = [NSArray arrayWithObjects:emailAddress, nil];
    mailController.mailComposeDelegate = self;
    [mailController setToRecipients:toRecipient];
    [mailController setSubject:@"Message from iStayHealthy..."];
    [self presentModalViewController:mailController animated:YES];
    [mailController release];
    
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
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            resultText = @"Result: failed";
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"iStayHealthy Email" 
                                                                message:resultText delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
            [alertView release];
            break;
        case MFMailComposeResultSaved:
            break;
    }
    [self dismissModalViewControllerAnimated:YES];
}



#pragma mark - Clinic Controllers


- (void)loadClinicAddViewController{
    ClinicAddTableViewController *newClinicController = [[ClinicAddTableViewController alloc] initWithRecord:self.masterRecord];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newClinicController];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];
	[navigationController release];
    [newClinicController release];
}

- (void)loadClinicChangeViewController{
    ClinicAddTableViewController *changeController = [[ClinicAddTableViewController alloc]initWithContacts:(Contacts *)[self.allContacts objectAtIndex:selectedContactRow] WithRecord:masterRecord];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:changeController];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];
	[navigationController release];  
    [changeController release];
}


#pragma mark - Other Medication Controllers

- (void)loadOtherMedicationDetailViewController{
	OtherMedicationDetailViewController *newMedsView = [[OtherMedicationDetailViewController alloc] initWithRecord:masterRecord];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newMedsView];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];
	[navigationController release];
    [newMedsView release];
    
}

- (void)loadOtherMedicationChangeViewController:(int) row{
    OtherMedication *otherMed = (OtherMedication *)[self.allPills objectAtIndex:row];
	OtherMedicationChangeViewController *changeMedsView = 
    [[OtherMedicationChangeViewController alloc] initWithOtherMedication:otherMed withMasterRecord:self.masterRecord];    
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:changeMedsView];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];
	[navigationController release];  
    [changeMedsView release];
}

#pragma mark - Procedure Controllers
- (void)loadProcedureAddViewController{
    ProcedureAddViewController *newProcController = [[ProcedureAddViewController alloc] initWithRecord:self.masterRecord];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newProcController];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];
	[navigationController release];  
    [newProcController release];
}

- (void)loadProcedureChangeViewController:(int)row{
    ProcedureChangeViewController *changeProcController = [[ProcedureChangeViewController alloc]
                                                           initWithProcedure:(Procedures *)[self.allProcedures objectAtIndex:row] withMasterRecord:self.masterRecord];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:changeProcController];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];
	[navigationController release]; 
    [changeProcController release];
}

#pragma mark - Cell management



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section) {
        return 1;
    }
    if (1 == section) {
        return [self.allPills count];
    }
    if (2 == section) {
        return [self.allProcedures count];
    }
    if (3 == section) {
#ifdef APPDEBUG
        NSLog(@"we have %d entries in the Contacts table",[self.allContacts count]);
#endif
        return [self.allContacts count];
    }
    return 0;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (0 == indexPath.section) {
        return 90.0;
    }
	return 70.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDateFormatter *formatter = [[[NSDateFormatter alloc]init]autorelease];
	formatter.dateFormat = @"dd MMM YYYY";
    if (0 == indexPath.section) {
        NSString *identifier = @"GeneralButtonCell";
        GeneralButtonCell *cell = (GeneralButtonCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if(nil == cell){
            NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"GeneralButtonCell" owner:self options:nil];
            for (id currentObject in cellObjects) {
                if ([currentObject isKindOfClass:[GeneralButtonCell class]]) {
                    cell = (GeneralButtonCell *)currentObject;
                    break;
                }
            }            
        }
        [cell setDelegate:self];
        cell.backgroundColor = DEFAULT_BACKGROUND;
        tableView.separatorColor = [UIColor clearColor];
        return cell;
    }
    if (1 == indexPath.section) {
        NSString *identifer = @"OtherMedCell";
        OtherMedCell *cell = (OtherMedCell *)[tableView dequeueReusableCellWithIdentifier:identifer];
        if(nil == cell){
            NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"OtherMedCell" owner:self options:nil];
            for (id currentObject in cellObjects) {
                if ([currentObject isKindOfClass:[OtherMedCell class]]) {
                    cell = (OtherMedCell *)currentObject;
                    break;
                }
            }                        
        }
        OtherMedication *med = (OtherMedication *)[self.allPills objectAtIndex:indexPath.row];
        [[cell dateLabel]setText:[formatter stringFromDate:med.StartDate]];
        [[cell nameLabel]setText:med.Name];
        [[cell drugLabel]setText:[NSString stringWithFormat:@"%2.2f %@",[med.Dose floatValue], med.Unit]];

        tableView.separatorColor = [UIColor lightGrayColor];
        return cell;
    }
    if (2 == indexPath.section) {
        NSString *identifier = @"ProcedureCell";
        ProcedureCell *cell = (ProcedureCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (nil == cell) {
            NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"ProcedureCell" owner:self options:nil];
            for (id currentObject in cellObjects) {
                if ([currentObject isKindOfClass:[ProcedureCell class]]) {
                    cell = (ProcedureCell *)currentObject;
                    break;
                }
            }                                    
        }
        Procedures *procs = (Procedures *)[self.allProcedures objectAtIndex:indexPath.row];
        NSString *procString = procs.Name;
        NSString *illString = procs.Illness;
        if ([procString isEqualToString:@""] && ![illString isEqualToString:@""]) {
            [[cell procLabel]setText:illString];
            [[cell illnessLabel]setText:@""];
        }
        if (![procString isEqualToString:@""] && [illString isEqualToString:@""]) {
            [[cell procLabel]setText:procString];
            [[cell illnessLabel]setText:@""];
        }
        if (![procString isEqualToString:@""] && ![illString isEqualToString:@""]) {
            [[cell procLabel]setText:procString];
            [[cell illnessLabel]setText:illString];
        }
        [[cell dateLabel]setText:[formatter stringFromDate:procs.Date]];
        tableView.separatorColor = [UIColor lightGrayColor];
        return cell;
    }
    if (3 == indexPath.section) {
        NSString *identifier = @"ClinicCell";
        ClinicCell *cell = (ClinicCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (nil == cell) {
            NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"ClinicCell" owner:self options:nil];
            for (id currentObject in cellObjects) {
                if ([currentObject isKindOfClass:[ClinicCell class]]) {
                    cell = (ClinicCell *)currentObject;
                    break;
                }
            }                                                
        }
        Contacts *contact = (Contacts *)[self.allContacts objectAtIndex:indexPath.row];
        [[cell clinicCell]setText:contact.ClinicName];
        tableView.separatorColor = [UIColor lightGrayColor];
        return cell;
    }
    return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = indexPath.section;
    switch (section) {
        case 1:
            [self loadOtherMedicationChangeViewController:indexPath.row];
            break;
        case 2:
            [self loadProcedureChangeViewController:indexPath.row];
            break;
        case 3:
            self.selectedContactRow = indexPath.row;
            [self showActionSheetForContact:indexPath.row];
            break;            
    }
}


@end
