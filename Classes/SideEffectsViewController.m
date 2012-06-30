//
//  SideEffectsViewController.m
//  iStayHealthy
//
//  Created by peterschmidt on 19/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SideEffectsViewController.h"
#import "iStayHealthyRecord.h"
#import "SideEffects.h"
#import "NSArray-Set.h"
#import "GeneralSettings.h"
#import "SideEffectListCell.h"
#import "SideEffectDetailViewController.h"

@interface SideEffectsViewController()
- (void)pushSideEffectsController;
@end

@implementation SideEffectsViewController
@synthesize record, sideeffects;

- (id)initWithRecord:(iStayHealthyRecord *)masterrecord
{
    self = [super initWithNibName:@"SideEffectsViewController" bundle:nil];
    if (self) {
        self.record = masterrecord;
        NSSet *effectSet = record.sideeffects;
        if (0 != [effectSet count]) {
            self.sideeffects = [NSArray arrayByOrderingSet:effectSet byKey:@"SideEffectDate" ascending:YES reverseOrder:YES];
        }
        else {//if empty - simply map to empty set
            self.sideeffects = (NSMutableArray *)effectSet;
        }
    }
    return self;
}


- (void)viewDidUnload{
    self.sideeffects = nil;
    [super viewDidUnload];
}

- (IBAction) done:				(id) sender{
    [self dismissModalViewControllerAnimated:YES];
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
	self.navigationItem.title = NSLocalizedString(@"Side Effects", @"Side Effects");
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] 
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                              target:self action:@selector(done:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(pushSideEffectsController)];
    self.tableView.rowHeight = 57.0;
}

- (void)pushSideEffectsController{
    SideEffectDetailViewController *sideEffectsController = [[SideEffectDetailViewController alloc]initWithNibName:@"SideEffectDetailViewController" bundle:nil];
    [self.navigationController pushViewController:sideEffectsController animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sideeffects count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"SideEffectListCell";
    SideEffectListCell *cell = (SideEffectListCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (nil == cell) {
        NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"SideEffectListCell" owner:self options:nil];
        for (id currentObject in cellObjects) {
            if ([currentObject isKindOfClass:[SideEffectListCell class]]) {
                cell = (SideEffectListCell *)currentObject;
                break;
            }
        }  
    }
    SideEffects *effect = (SideEffects *)[self.sideeffects objectAtIndex:indexPath.row];
	NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
	formatter.dateFormat = @"dd MMM YYYY";
    [[cell date]setText:[formatter stringFromDate:effect.SideEffectDate]];
    [[cell effect]setText:effect.SideEffect];
    [[cell drug]setText:effect.Name];
    [[cell imageView]setImage:[UIImage imageNamed:@"sideeffects.png"]];
    return cell;
}


#pragma mark - Table view delegate


/**
 only row deletion is enabled. row is removed and entry is deleted from the database
 @tableView
 @editingStyle
 @indexPath
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete && 0 == indexPath.section) {
		SideEffects *effects = (SideEffects *)[self.sideeffects objectAtIndex:indexPath.row];
        [record removeSideeffectsObject:effects];
		[self.sideeffects removeObject:effects];
		NSManagedObjectContext *context = effects.managedObjectContext;
		[context deleteObject:effects];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
		NSError *error = nil;
		if (![context save:&error]) {
#ifdef APPDEBUG
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
			abort();
		}
    }   
}
 */

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}



@end
