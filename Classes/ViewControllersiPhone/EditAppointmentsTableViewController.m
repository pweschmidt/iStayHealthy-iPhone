//
//  EditAppointmentsTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/09/2013.
//
//

#import "EditAppointmentsTableViewController.h"

@interface EditAppointmentsTableViewController ()
@property (nonatomic, strong) NSArray *clinics;
@end

@implementation EditAppointmentsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
     currentClinics:(NSArray *)currentClinics
      managedObject:(NSManagedObject *)managedObject
{
    self = [super initWithStyle:style managedObject:managedObject hasNumericalInput:NO];
    if (nil != self)
    {
        if (nil == currentClinics)
        {
            _clinics = [NSArray array];
        }
        else
        {
            _clinics = currentClinics;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)setDefaultValues
{
    
}

- (void)save:(id)sender
{
    
}

- (void)deleteObject:(id)sender
{
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
