//
//  EditDashboardTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 18/10/2013.
//
//

#import "EditDashboardTableViewController.h"

@interface EditDashboardTableViewController ()
@property (nonatomic, strong) NSArray *editMenu;
@property (nonatomic, strong) NSMutableArray *selectedDashboards;
@end

@implementation EditDashboardTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.editMenu = @[kCD4,
                      kCD4Percent,
                      kGlucose,
                      kTotalCholesterol,
                      kLDL,
                      kHemoglobulin,
                      kWhiteBloodCells,
                      kRedBloodCells,
                      kPlatelet,
                      kWeight,
                      kBMI,
                      kBloodPressure,
                      kCardiacRiskFactor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setDefaultValues
{
    
}

@end
