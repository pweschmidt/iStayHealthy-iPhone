//
//  CustomTableView.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 23/08/2013.
//
//

#import "CustomTableView.h"

@interface CustomTableView ()
@property (nonatomic, strong, readwrite) NSArray * menuItems;
@property (nonatomic, assign) MenuType type;
- (id)initWithMenus:(NSArray *)menus frame:(CGRect)frame;
@end

@implementation CustomTableView

+ (CustomTableView *)customTableViewWithMenus:(NSArray *)menus
                                        frame:(CGRect)frame
                                         type:(MenuType)type
{
    CustomTableView *tableView = [[CustomTableView alloc] initWithMenus:menus frame:frame];
    tableView.type = type;
    return tableView;
}

- (id)initWithMenus:(NSArray *)menus
              frame:(CGRect)frame
{
    self = [self initWithFrame:frame style:UITableViewStyleGrouped];
    if (nil != self)
    {
        _menuItems = menus;
        self.dataSource = self;
        self.delegate = self;
    }
    return self;
}

#pragma mark datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"numberOfSectionsInTableView");
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"we have %d menu items to show", self.menuItems.count);
    return self.menuItems.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    NSLog(@"Cell %d", indexPath.row);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    NSLog(@"loading cell %d", indexPath.row);
    if (0 == indexPath.row)
    {
        cell.textLabel.text = @"X";
    }
    else
    {
        cell.textLabel.text = [self.menuItems objectAtIndex:indexPath.row - 1];
    }
    return cell;
}

#pragma tableview delegate
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.row)
    {
        switch (self.type)
        {
            case HamburgerMenuType:
                [self.containerDelegate slideOutHamburger];
                break;
            case AddMenuType:
                [self.containerDelegate slideOutAdder];
                break;
        }
    }
}

@end
