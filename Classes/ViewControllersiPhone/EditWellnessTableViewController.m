//
//  EditWellnessTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/09/2013.
//
//

#import "EditWellnessTableViewController.h"

@interface EditWellnessTableViewController ()

@end

@implementation EditWellnessTableViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)save:(id)sender
{
	[super save:sender];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (0 == indexPath.section)
	{
		return ([self indexPathHasPicker:indexPath] ? kBaseDateCellRowHeight : self.tableView.rowHeight);
	}
	else
	{
		return self.tableView.rowHeight;
	}
}

@end
