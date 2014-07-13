//
//  EditContactsTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 02/10/2013.
//
//

#import "EditContactsTableViewController.h"
#import "Constants.h"
#import "CoreDataManager.h"
#import "Contacts+Handling.h"
#import "Utilities.h"
#import "UILabel+Standard.h"

@interface EditContactsTableViewController ()
@property (nonatomic, strong) NSArray *editMenu;
@property (nonatomic, strong) NSMutableArray *titleStrings;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) NSMutableDictionary *valueMap;
@property (nonatomic, strong) NSString *callNumber;
@property (nonatomic, strong) NSString *emergencyNumber;
@property (nonatomic, strong) NSString *webSite;
@property (nonatomic, strong) NSString *email;
@end

@implementation EditContactsTableViewController
- (id)  initWithStyle:(UITableViewStyle)style
        managedObject:(NSManagedObject *)managedObject
    hasNumericalInput:(BOOL)hasNumericalInput
{
	self = [super initWithStyle:style managedObject:managedObject hasNumericalInput:hasNumericalInput];
	if (nil != self)
	{
		[self populateValueMap];
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	if (self.isEditMode)
	{
		self.navigationItem.title = NSLocalizedString(@"Edit Clinic", nil);
		self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 44);
		if (![Utilities isIPad])
		{
			[self createToolbarButtons];
		}
	}
	else
	{
		self.navigationItem.title = NSLocalizedString(@"New Clinic", nil);
	}
	self.titleStrings = [NSMutableArray arrayWithCapacity:self.editMenu.count];
}

- (void)createToolbarButtons
{
	self.toolbar = [[UIToolbar alloc] init];
	self.toolbar.frame = CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44);
	UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc]
	                                  initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
	                                                       target:self
	                                                       action:nil];
	NSMutableArray *buttons = [NSMutableArray array];
	[buttons addObject:flexibleSpace];
	Contacts *contacts = (Contacts *)self.managedObject;
	NSUInteger realButtonCount = 0;
	if (nil != contacts.ClinicContactNumber && 0 < contacts.ClinicContactNumber.length)
	{
		self.callNumber = contacts.ClinicContactNumber;
		UIBarButtonItem *callButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Call", nil) style:UIBarButtonItemStylePlain target:self action:@selector(callNumber)];
		[buttons addObject:callButton];
		[buttons addObject:flexibleSpace];
		realButtonCount++;
	}
	if (nil != contacts.EmergencyContactNumber && 0 < contacts.EmergencyContactNumber.length)
	{
		self.emergencyNumber = contacts.EmergencyContactNumber;
		UIBarButtonItem *callButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Emergency", nil) style:UIBarButtonItemStylePlain target:self action:@selector(callEmergency)];
		[buttons addObject:callButton];
		[buttons addObject:flexibleSpace];
		realButtonCount++;
	}
	if (nil != contacts.ClinicWebSite && 0 < contacts.ClinicWebSite.length)
	{
		self.webSite = contacts.ClinicWebSite;
		UIBarButtonItem *callButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Website", nil) style:UIBarButtonItemStylePlain target:self action:@selector(gotoWebsite)];
		[buttons addObject:callButton];
		[buttons addObject:flexibleSpace];
		realButtonCount++;
	}
	if (0 < realButtonCount)
	{
		self.toolbar.items = buttons;

		[self.view addSubview:self.toolbar];
	}
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (void)populateValueMap
{
	self.valueMap = [NSMutableDictionary dictionary];
	self.editMenu = @[kClinicName,
	                  kClinicID,
	                  kClinicWebSite,
	                  kClinicEmailAddress,
	                  kClinicContactNumber,
	                  kEmergencyContactNumber];
	if (!self.isEditMode)
	{
		return;
	}
	Contacts *contacts = (Contacts *)self.managedObject;
	NSDictionary *attributes = [[contacts entity] attributesByName];
	for (NSString *attribute in attributes)
	{
		if (![attribute isEqualToString:kUID])
		{
			id value = [contacts valueForKey:attribute];
			if (nil != value && [self.editMenu containsObject:attribute])
			{
				[self.valueMap setObject:value forKey:attribute];
			}
		}
	}
}

- (void)save:(id)sender
{
	Contacts *contact = nil;
	if (self.isEditMode)
	{
		contact = (Contacts *)self.managedObject;
	}
	else
	{
		contact = [[CoreDataManager sharedInstance] managedObjectForEntityName:kContacts];
	}
	contact.UID = [Utilities GUID];
	NSDictionary *attributes = [[contact entity] attributesByName];
	for (NSString *attribute in attributes.allKeys)
	{
		if ([attribute isEqualToString:kUID])
		{
			contact.UID = [Utilities GUID];
		}
		else if ([self.editMenu containsObject:attribute])
		{
			NSString *value = [self.valueMap objectForKey:attribute];
			if (nil != value && ![value isEqualToString:@""])
			{
				[contact setValue:value forKey:attribute];
			}
		}
	}

	NSError *error = nil;
	[[CoreDataManager sharedInstance] saveContextAndWait:&error];
	[self popController];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.editMenu.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *identifier = @"ContactCell";
	PWESCustomTextfieldCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (nil == cell)
	{
		cell = [[PWESCustomTextfieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
	}
	NSString *resultsString = [self.editMenu objectAtIndex:indexPath.row];
	NSString *text = NSLocalizedString(resultsString, nil);
	[self configureTableCell:cell title:text indexPath:indexPath hasNumericalInput:NO];
	return cell;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	[super textFieldDidEndEditing:textField];
	if (nil == textField.text
	    || [textField.text isEqualToString:@""]
	    || [textField.text isEqualToString:textField.placeholder])
	{
		return;
	}
	//for segment = 0 we have 10^0 + indexPath.row as tag, i.e. tag - 1 gives us the index path
	NSInteger tag = textField.tag - 1;
	if (0 <= tag && self.editMenu.count > tag)
	{
		NSString *attribute = [self.editMenu objectAtIndex:tag];
		[self.valueMap setObject:textField.text forKey:attribute];
	}
}

- (void)configureTableCell:(PWESCustomTextfieldCell *)cell
                     title:(NSString *)title
                 indexPath:(NSIndexPath *)indexPath
         hasNumericalInput:(BOOL)hasNumericalInput
{
	[super configureTableCell:cell title:title indexPath:indexPath hasNumericalInput:hasNumericalInput];
	NSNumber *tagNumber = [self tagNumberForIndex:indexPath.row segment:0];
	UITextField *textField = [self customTextFieldForTagNumber:tagNumber];
	if (nil == textField)
	{
		return;
	}
	NSString *attribute = [self.editMenu objectAtIndex:indexPath.row];
	NSString *value = [self.valueMap objectForKey:attribute];
	if (nil != value && ![value isEqualToString:@""])
	{
		textField.text = value;
		textField.textColor = [UIColor blackColor];
	}
	else
	{
		textField.textColor = [UIColor lightGrayColor];
		textField.text = textField.placeholder;
	}
	if ([title isEqualToString:NSLocalizedString(kClinicEmailAddress, nil)])
	{
		cell.adjustedKeyboardType = UIKeyboardTypeEmailAddress;
	}
	else if ([title isEqualToString:NSLocalizedString(kClinicWebSite, nil)])
	{
		cell.adjustedKeyboardType = UIKeyboardTypeURL;
	}
}

#pragma mark toolbar button items
- (void)callContact
{
	if (nil != self.callNumber && 0 < self.callNumber.length)
	{
		NSString *tel = [NSString stringWithFormat:@"tel:%@", self.callNumber];
		NSURL *url = [NSURL URLWithString:tel];
		[[UIApplication sharedApplication] openURL:url];
	}
}

- (void)callEmergency
{
	if (nil != self.emergencyNumber && 0 < self.emergencyNumber.length)
	{
		NSString *tel = [NSString stringWithFormat:@"tel:%@", self.emergencyNumber];
		NSURL *url = [NSURL URLWithString:tel];
		[[UIApplication sharedApplication] openURL:url];
	}
}

- (void)gotoWebsite
{
	if (nil != self.webSite && 0 < self.webSite.length)
	{
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.webSite]];
	}
}

@end
