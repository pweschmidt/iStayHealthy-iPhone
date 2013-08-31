//
//  EditHIVMedsTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 31/08/2013.
//
//

#import "EditHIVMedsTableViewController.h"

@interface EditHIVMedsTableViewController ()
@property (nonatomic, strong) NSArray *combiTablets;
@property (nonatomic, strong) NSArray *proteaseInhibitors;
@property (nonatomic, strong) NSArray *nRTInihibtors;
@property (nonatomic, strong) NSArray *nNRTInhibitors;
@property (nonatomic, strong) NSArray *integraseInhibitors;
@property (nonatomic, strong) NSArray *entryInhibitors;
@property (nonatomic, strong) NSMutableDictionary *stateDictionary;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSArray * meds;
@property (nonatomic, assign) BOOL isInEditMode;
@property (nonatomic, assign) BOOL isInitialLoad;
@end

@implementation EditHIVMedsTableViewController

- (id)init
{
    return [self initWithStyle:UITableViewStyleGrouped meds:nil];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    return [self initWithStyle:style meds:nil];
}

- (id)initWithStyle:(UITableViewStyle)style meds:(NSArray *)meds
{
    self = [super initWithStyle:style];
    if (self)
    {
        _meds  = meds;
        if (nil != meds)
        {
            _isInEditMode = YES;
        }
        else
        {
            _isInEditMode = NO;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.isInEditMode)
    {
        self.navigationItem.title = NSLocalizedString(@"Edit HIV Drugs", nil);
    }
    else
    {
        self.navigationItem.title = NSLocalizedString(@"Add HIV Drugs", nil);
    }
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                              target:self action:@selector(save:)];
    [self loadDrugs];
}

- (void)loadDrugs
{
    NSString *combipath = [[NSBundle mainBundle] pathForResource:@"CombiMeds" ofType:@"plist"];
    NSArray *tmp1 = [[NSArray alloc]initWithContentsOfFile:combipath];
    self.combiTablets = tmp1;
    
    NSString *nrtiPath = [[NSBundle mainBundle] pathForResource:@"NRTI" ofType:@"plist"];
    NSArray *tmp2 = [[NSArray alloc]initWithContentsOfFile:nrtiPath];
    self.nRTInihibtors = tmp2;
    
    NSString *proteasePath = [[NSBundle mainBundle] pathForResource:@"ProteaseInhibitors" ofType:@"plist"];
    NSArray *tmp3 = [[NSArray alloc]initWithContentsOfFile:proteasePath];
    self.proteaseInhibitors = tmp3;
    
    NSString *nnrtiPath = [[NSBundle mainBundle] pathForResource:@"NNRTI" ofType:@"plist"];
    NSArray *tmp4 = [[NSArray alloc]initWithContentsOfFile:nnrtiPath];
    self.nNRTInhibitors = tmp4;
    
    NSString *entryPath = [[NSBundle mainBundle] pathForResource:@"EntryInhibitors" ofType:@"plist"];
    NSArray *tmp5 = [[NSArray alloc]initWithContentsOfFile:entryPath];
    self.entryInhibitors = tmp5;
    
    NSString *integrasePath = [[NSBundle mainBundle] pathForResource:@"IntegraseInhibitors" ofType:@"plist"];
    NSArray *tmp6 = [[NSArray alloc]initWithContentsOfFile:integrasePath];
    self.integraseInhibitors = tmp6;
    
    self.startDate = [NSDate date];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 7;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rows = 1;
    switch (section)
    {
        case 1:
            rows = [self.combiTablets count];
            break;
        case 2:
            rows = [self.entryInhibitors count];
            break;
        case 3:
            rows = [self.integraseInhibitors count];
            break;
        case 4:
            rows = [self.nNRTInhibitors count];
            break;
        case 5:
            rows = [self.nRTInihibtors count];
            break;
        case 6:
            rows = [self.proteaseInhibitors count];
            break;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *text = @"";
    switch (section)
    {
        case 1:
            text = NSLocalizedString(@"Combination Tablets",nil);
            break;
        case 2:
            text = NSLocalizedString(@"Fusion/Entry Inhibitors",nil);
            break;
        case 3:
            text = NSLocalizedString(@"Integrase Inhibitors",nil);
            break;
        case 4:
            text = NSLocalizedString(@"non-Nucleoside Reverse Transcriptase Inhibitors",nil);
            break;
        case 5:
            text = NSLocalizedString(@"Nucleos(t)ide Reverse Transcriptase Inhibitors",nil);
            break;
        case 6:
            text = NSLocalizedString(@"Protease Inhibitors",nil);
            break;
    }
    return text;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
