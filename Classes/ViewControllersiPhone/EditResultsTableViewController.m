//
//  EditResultsTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 13/08/2013.
//
//

#import "EditResultsTableViewController.h"
#import "Constants.h"
#import "CoreDataManager.h"
#import "Results+Handling.h"
#import "Utilities.h"

@interface EditResultsTableViewController ()
{
    CGRect labelFrame;
    CGRect separatorFrame;
    CGRect textViewFrame;
}
@property (nonatomic, strong) NSArray * editResultsMenu;
@property (nonatomic, strong) NSMutableArray *textViews;
@property (nonatomic, strong) Results * currentResults;
@property (nonatomic, assign) BOOL isInEditMode;

@end

@implementation EditResultsTableViewController

- (id)init
{
    return [self initWithStyle:UITableViewStyleGrouped results:nil];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    return [self initWithStyle:style results:nil];
}

- (id)initWithStyle:(UITableViewStyle)style
            results:(Results *)results
{
    self = [super initWithStyle:style];
    if (self)
    {
        _currentResults = results;
        if (nil != results)
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
    labelFrame = CGRectMake(20, 0, 115, 44);
    separatorFrame = CGRectMake(117, 4, 2, 40);
    textViewFrame = CGRectMake(120, 0, 150, 44);
    self.navigationItem.title = NSLocalizedString(@"New Result", nil);
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                             target:self action:@selector(save:)];
    self.editResultsMenu = @[kCD4,
                             kCD4Percent,
                             kViralLoad,
                             kHepCViralLoad,
                             kGlucose,
                             kTotalCholesterol,
                             kHDL,
                             kLDL,
                             kHemoglobulin,
                             kWhiteBloodCells,
                             kRedBloodCells,
                             kPlatelet,
                             kWeight,
                             kSystole,
                             kDiastole,
                             kCardiacRiskFactor];
    self.textViews = [NSMutableArray arrayWithCapacity:self.editResultsMenu.count];
}

- (IBAction)save:(id)sender
{

    if (nil == self.currentResults)
    {
        self.currentResults = [[CoreDataManager sharedInstance] managedObjectForEntityName:kResults];
        self.currentResults.UID = [Utilities GUID];
        self.currentResults.ResultsDate = [NSDate date];
        [self.textViews enumerateObjectsUsingBlock:^(UITextView *view, NSUInteger index, BOOL *stop) {
            NSString *valueString = view.text;
            NSString *type = [self.editResultsMenu objectAtIndex:index];
            [self.currentResults addValueString:valueString type:type];
        }];
        
    }
    NSError *error = nil;
    [[CoreDataManager sharedInstance] saveContext:&error];
    
    [self.navigationController popViewControllerAnimated:YES];
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
    return self.editResultsMenu.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"ResultsCell%d",indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [self configureResultsCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureResultsCell:(UITableViewCell *)resultsCell
                 atIndexPath:(NSIndexPath *)indexPath
{
    UILabel *title = [[UILabel alloc] initWithFrame:labelFrame];
    NSString *text = NSLocalizedString([self.editResultsMenu objectAtIndex:indexPath.row], nil);
    title.text = text;
    title.backgroundColor = [UIColor clearColor];
    
    UIView *separator = [[UIView alloc] initWithFrame:separatorFrame];
    separator.backgroundColor = [UIColor lightGrayColor];
    
    UITextField *textField = [[UITextField alloc] initWithFrame:textViewFrame];
    textField.delegate = self;
    textField.tag = indexPath.row;
    textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    textField.keyboardAppearance = UIKeyboardAppearanceLight;
    [self.textViews insertObject:textField atIndex:indexPath.row];
 
    [resultsCell addSubview:title];
    [resultsCell addSubview:separator];
    [resultsCell addSubview:textField];
}

#pragma mark - UITextViewDelegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.textColor = [UIColor blackColor];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    NSString *separator = [[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator];
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString *expression = nil;
    
    int tag = textField.tag;
    BOOL isIntegerField = (0 == tag || 2 == tag || 3 == tag || 9 == tag || 10 == tag || 11 == tag || 13 == tag || 14 == tag);
    
    if (isIntegerField)
    {
        expression = @"^([0-9]+)?$";
    }
    else
    {
        if ([@"." isEqualToString:separator])
        {
            expression = @"^([0-9]{1,3})?(\\.([0-9]{1,2})?)?$";
        }
        else
        {
            expression = @"^([0-9]{1,3})?(,([0-9]{1,2})?)?$";
        }
    }
    
    
    NSError *error = nil;
    
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:expression
                                  options:NSRegularExpressionCaseInsensitive
                                  error:&error];
    if (error)
    {
        return YES;
    }
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:newString
                                                        options:0
                                                          range:NSMakeRange(0, [newString length])];
    
    if (0 < numberOfMatches)
    {
        return YES;
    }
    return NO;
}


@end
