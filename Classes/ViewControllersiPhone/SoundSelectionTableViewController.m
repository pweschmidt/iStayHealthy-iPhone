//
//  SoundSelectionTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 05/07/2014.
//
//

#import "SoundSelectionTableViewController.h"
#import "Menus.h"
#import "UILabel+Standard.h"

@interface SoundSelectionTableViewController ()
@property (nonatomic, strong) NSArray *sounds;
@property (nonatomic, strong) NSIndexPath *selectedSoundPath;
@end

@implementation SoundSelectionTableViewController


- (void)viewDidLoad
{
	[super viewDidLoad];
	self.navigationItem.title = NSLocalizedString(@"Select Sound", nil);
	NSArray *names = [Menus soundFiles].allKeys;
	self.sounds = [names sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
	self.tableView.backgroundColor = DEFAULT_BACKGROUND;
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.sounds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *identifier = @"identifier";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (nil == cell)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
	}
	UILabel *label = (UILabel *)[cell.contentView viewWithTag:10];

	if (nil == label)
	{
		label = [UILabel standardLabel];
		label.frame = CGRectMake(20, 0, 180, self.tableView.rowHeight);
		label.text = [self.sounds objectAtIndex:indexPath.row];
		label.tag = 10;
		[cell.contentView addSubview:label];
	}

	if (nil != self.previousSound && [self.previousSound isEqualToString:label.text])
	{
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		self.selectedSoundPath = indexPath;
	}

	return cell;
}

- (void)deselect:(id)sender
{
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
	if (nil != self.selectedSoundPath)
	{
		UITableViewCell *checkedCell = [self.tableView cellForRowAtIndexPath:self.selectedSoundPath];
		checkedCell.accessoryType = UITableViewCellAccessoryNone;
	}
	cell.accessoryType = UITableViewCellAccessoryCheckmark;
	self.selectedSoundPath = indexPath;

	__strong id <SoundSelector> strongSelector = self.soundDelegate;
	if (nil != strongSelector && [strongSelector respondsToSelector:@selector(selectedSound:)])
	{
		UILabel *label = (UILabel *)[cell.contentView viewWithTag:10];
		if (nil != label)
		{
			[strongSelector selectedSound:label.text];
		}
	}

	[self performSelector:@selector(deselect:) withObject:nil afterDelay:0.5f];
}

@end
