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
		self.toolbar = [[UIToolbar alloc] init];
		self.toolbar.frame = CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44);
		[self.view addSubview:self.toolbar];
	}
	else
	{
		self.navigationItem.title = NSLocalizedString(@"New Clinic", nil);
	}
	self.titleStrings = [NSMutableArray arrayWithCapacity:self.editMenu.count];
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
	[[CoreDataManager sharedInstance] saveContext:&error];
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

- (void)configureTableCell:(PWESCustomTextfieldCell *)cell title:(NSString *)title indexPath:(NSIndexPath *)indexPath hasNumericalInput:(BOOL)hasNumericalInput
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
}

@end
