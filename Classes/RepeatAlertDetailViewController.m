//
//  RepeatAlertDetailViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 29/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RepeatAlertDetailViewController.h"
#import "EditableTableCell.h"

@implementation RepeatAlertDetailViewController
@synthesize lastSelectedCell;
@synthesize delegate;

#pragma mark -
#pragma mark View lifecycle

/**
 loads the view
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    lastSelectedCell = nil;
}


/**
 just before view is called. n
 @animated
 */
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	initialLoad = YES;
}


#pragma mark -
#pragma mark Table view data source

/**
 2 sections are created
 @tableView
 @return NSInteger
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

/**
 section 0 has the repeat intervals. section 1 indicates this is a one-off alert
 @return NSInteger
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (0 == section) {
		return 4;
	}
    return 1;
}

/**
 loads/sets up the cells
 @tableView
 @indexPath
 @return UITableViewCell
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    EditableTableCell *cell = (EditableTableCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[EditableTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	cell.editableCellLabel.text = NSLocalizedString(@"Repeats",@"Repeats");
    cell.editableCellTextField.enabled = NO;

    if (0 == indexPath.section) {
		switch (indexPath.row) {
			case 0:
				cell.editableCellTextField.text = NSLocalizedString(@"Every 24 hours",@"Every 24 hours");
				if (initialLoad) {
					initialLoad = NO;
                    lastSelectedCell = cell;
                    lastSelectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
				}
				break;
			case 1:
				cell.editableCellTextField.text = NSLocalizedString(@"Every 12 hours",@"Every 12 hours");
				break;
			case 2:
				cell.editableCellTextField.text = NSLocalizedString(@"Every 8 hours",@"Every 8 hours");
				break;
			case 3:
				cell.editableCellTextField.text = NSLocalizedString(@"Every 6 hours",@"Every 6 hours");
				break;
		}
	}
	else {
		cell.editableCellTextField.text = NSLocalizedString(@"Never",@"Never");
	}
	cell.selectionStyle= UITableViewCellSelectionStyleGray;

	
    return (UITableViewCell *)cell;
}




#pragma mark -
#pragma mark Table view delegate
/**
 sets the timing of the deselect
 @id
 */
- (void) deselect: (id) sender
{
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}
/**
 when selected the checkbox appears in the row.
 @tableView
 @indexPath
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!lastSelectedCell) {
#ifdef APPDEBUG
        NSLog(@"lastSelectedCell is nil"); 
#endif
        return;
    }
    lastSelectedCell.accessoryType = UITableViewCellAccessoryNone;
	EditableTableCell *selectedCell = (EditableTableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
	selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
#ifdef APPDEBUG
	NSLog(@"in RepeatAlertDetailViewController: selected text is %@",selectedCell.editableCellTextField.text);
#endif
	[self.delegate setRepeatIntervalText:selectedCell.editableCellTextField.text];
    [self performSelector:@selector(deselect:) withObject:nil afterDelay:0.5f];
    lastSelectedCell = selectedCell;
	
}


#pragma mark -
#pragma mark Memory management
/**
 handles memory warnings
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
/**
 unloads view
 */
- (void)viewDidUnload {
	[super viewDidUnload];
    lastSelectedCell = nil;
}

/**
 dealloc
 */
- (void)dealloc {
    [super dealloc];
    [lastSelectedCell release];
}


@end

