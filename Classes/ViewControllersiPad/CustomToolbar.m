//
//  CustomToolbar.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 08/02/2014.
//
//

#import "CustomToolbar.h"
#import "UIBarButtonItem+iStayHealthy.h"
#import "Menus.h"

@interface CustomToolbar ()
{
    CGRect popUpFrame;
}
@property (nonatomic, strong) NSMutableArray *barButtons;
@property (nonatomic, weak) id <PWESToolbarDelegate> toolbarManager;
@end

@implementation CustomToolbar

- (instancetype)initWithToolbarManager:(id<PWESToolbarDelegate>)toolbarManager
{
    self = [super init];
    if (nil != self)
    {
        _toolbarManager = toolbarManager;
        [self addCustomBarbuttons];
    }
    return self;
}

// - (id)initWithFrame:(CGRect)frame
// {
//	self = [super initWithFrame:frame];
//	if (self)
//	{
//		[self addCustomBarbuttons];
//	}
//	return self;
// }

- (void)addCustomBarbuttons
{
    NSArray *buttonTypes = [Menus toolbarButtonItems];

    self.barButtons = [NSMutableArray array];
    UIBarButtonItem *initialSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];

    __block NSMutableArray *buttons = [NSMutableArray arrayWithCapacity:buttonTypes.count];

    [buttons addObject:initialSpace];
    UIView *customView = [self customAddMenuView];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithCustomView:customView];
    [buttons addObject:addButton];
    [buttons addObject:initialSpace];
    [buttons addObject:initialSpace];
    [buttonTypes enumerateObjectsUsingBlock: ^(NSString *title, NSUInteger index, BOOL *stop) {
         UIBarButtonItem *barbutton = nil;
         if ([title isEqualToString:NSLocalizedString(@"Settings", nil)])
         {
             barbutton = [UIBarButtonItem barButtonItemForTitle:title target:self action:@selector(openSettings:) buttonTag:index];
         }
         else if ([title isEqualToString:NSLocalizedString(@"Backups", nil)])
         {
             barbutton = [UIBarButtonItem barButtonItemForTitle:title target:self action:@selector(openBackup:) buttonTag:index];
         }
//         else if ([title isEqualToString:NSLocalizedString(@"Feedback", nil)])
//         {
//             barbutton = [UIBarButtonItem barButtonItemForTitle:title target:self action:@selector(openFeedback) buttonTag:index];
//         }
         else if ([title isEqualToString:NSLocalizedString(@"Email Data", nil)])
         {
             barbutton = [UIBarButtonItem barButtonItemForTitle:title target:self action:@selector(showFeedbackController:) buttonTag:index];
         }
         else if ([title isEqualToString:NSLocalizedString(@"Info", nil)])
         {
             barbutton = [UIBarButtonItem barButtonItemForTitle:title target:self action:@selector(openInfo:) buttonTag:index];
         }
         else if ([title isEqualToString:NSLocalizedString(@"LocalBackups", nil)])
         {
             barbutton = [UIBarButtonItem barButtonItemForTitle:title target:self action:@selector(openLocalBackup:) buttonTag:index];
         }
//         else if ([title isEqualToString:NSLocalizedString(@"Help", nil)])
//         {
//             barbutton = [UIBarButtonItem barButtonItemForTitle:title target:self action:@selector(openHelp:) buttonTag:index];
//         }
         if (nil != barbutton)
         {
             [self.barButtons addObject:barbutton];
         }
         UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
         if (nil != barbutton)
         {
             [buttons addObject:barbutton];
             [buttons addObject:flexibleSpace];
         }
     }];

    self.customItems = buttons;

//    [self setItems:buttons];
}

- (UIView *)customAddMenuView
{
    UIView *view = [UIView new];
    view.frame = CGRectMake(0, 0, 44, 44);
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, -18, 60, 60);
    button.backgroundColor = DARK_BLUE;
    button.layer.cornerRadius = 30.0;
    button.layer.borderWidth = 1.0;
    button.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [button addTarget:self action:@selector(showAddMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UILabel *label = [UILabel new];
    label.frame = CGRectMake(0, 0, 60, 60);
    label.font = [UIFont boldSystemFontOfSize:24.0];
    label.text = NSLocalizedString(@"Add", nil);
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    
    [button addSubview:label];
    [view addSubview:button];
    return view;
}



- (void)showFeedbackController:(id)sender
{
    if (nil != self.toolbarManager && nil != sender)
    {
        __strong id <PWESToolbarDelegate> strongDelegate = self.toolbarManager;
        if ([sender isKindOfClass:[UIBarButtonItem class]])
        {
            if ([strongDelegate respondsToSelector:@selector(showMailSelectionControllerFromButton::)])
            {
                [strongDelegate showMailSelectionControllerFromButton:(UIBarButtonItem *) sender];
            }
        }
        else if ([sender isKindOfClass:[UIButton class]])
        {
            UIButton *button = (UIButton *) sender;
            UIBarButtonItem *barButton = [self.barButtons objectAtIndex:button.tag];
            if ([strongDelegate respondsToSelector:@selector(showMailSelectionControllerFromButton:)])
            {
                [strongDelegate showMailSelectionControllerFromButton:barButton];
            }
        }
    }

}

- (void)openFeedback
{
    if (nil != self.toolbarManager)
    {
        __strong id <PWESToolbarDelegate> strongDelegate = self.toolbarManager;
        if ([strongDelegate respondsToSelector:@selector(showMailControllerHasAttachment:)])
        {
            [strongDelegate showMailControllerHasAttachment:NO];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];

    if ([title isEqualToString:NSLocalizedString(@"Yes", @"Yes")])
    {
        if (nil != self.toolbarManager)
        {
            __strong id <PWESToolbarDelegate> strongDelegate = self.toolbarManager;
            if ([strongDelegate respondsToSelector:@selector(showMailControllerHasAttachment:)])
            {
                [strongDelegate showMailControllerHasAttachment:NO];
            }
        }
    }
}


- (void)openMailWithAttachment
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Send data?", nil)
                                                    message:NSLocalizedString(@"You are about to email data. Click Yes if you want to continue.", nil)
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                          otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];

    [alert show];
}


- (void)openSettings:(id)sender
{
    if (nil != self.toolbarManager && nil != sender)
    {
        __strong id <PWESToolbarDelegate> strongDelegate = self.toolbarManager;
        if ([sender isKindOfClass:[UIBarButtonItem class]])
        {
            if ([strongDelegate respondsToSelector:@selector(showPasswordControllerFromButton:)])
            {
                [strongDelegate showPasswordControllerFromButton:(UIBarButtonItem *) sender];
            }
        }
        else if ([sender isKindOfClass:[UIButton class]])
        {
            UIButton *button = (UIButton *) sender;
            UIBarButtonItem *barButton = [self.barButtons objectAtIndex:button.tag];
            if ([strongDelegate respondsToSelector:@selector(showPasswordControllerFromButton:)])
            {
                [strongDelegate showPasswordControllerFromButton:barButton];
            }
        }
    }
}

- (void)openInfo:(UIBarButtonItem *)sender
{
    if (nil != self.toolbarManager && nil != sender)
    {
        __strong id <PWESToolbarDelegate> strongDelegate = self.toolbarManager;
        if ([sender isKindOfClass:[UIBarButtonItem class]])
        {
            if ([strongDelegate respondsToSelector:@selector(showInfoControllerFromButton:)])
            {
                [strongDelegate showInfoControllerFromButton:(UIBarButtonItem *) sender];
            }
        }
        else if ([sender isKindOfClass:[UIButton class]])
        {
            UIButton *button = (UIButton *) sender;
            UIBarButtonItem *barButton = [self.barButtons objectAtIndex:button.tag];
            if ([strongDelegate respondsToSelector:@selector(showInfoControllerFromButton:)])
            {
                [strongDelegate showInfoControllerFromButton:barButton];
            }
        }
    }
}

- (void)openHelp:(UIBarButtonItem *)sender
{
    if (nil != self.toolbarManager && nil != sender)
    {
        __strong id <PWESToolbarDelegate> strongDelegate = self.toolbarManager;
        if ([sender isKindOfClass:[UIBarButtonItem class]])
        {
            if ([strongDelegate respondsToSelector:@selector(showHelpControllerFromButton:)])
            {
                [strongDelegate showHelpControllerFromButton:(UIBarButtonItem *) sender];
            }
        }
        else if ([sender isKindOfClass:[UIButton class]])
        {
            UIButton *button = (UIButton *) sender;
            UIBarButtonItem *barButton = [self.barButtons objectAtIndex:button.tag];
            if ([strongDelegate respondsToSelector:@selector(showHelpControllerFromButton:)])
            {
                [strongDelegate showHelpControllerFromButton:barButton];
            }
        }
    }
}

- (void)openBackup:(UIBarButtonItem *)sender
{
    if (nil != self.toolbarManager && nil != sender)
    {
        __strong id <PWESToolbarDelegate> strongDelegate = self.toolbarManager;
        if ([sender isKindOfClass:[UIBarButtonItem class]])
        {
            if ([strongDelegate respondsToSelector:@selector(showPasswordControllerFromButton:)])
            {
                [strongDelegate showDropboxControllerFromButton:(UIBarButtonItem *) sender];
            }
        }
        else if ([sender isKindOfClass:[UIButton class]])
        {
            UIButton *button = (UIButton *) sender;
            UIBarButtonItem *barButton = [self.barButtons objectAtIndex:button.tag];
            if ([strongDelegate respondsToSelector:@selector(showPasswordControllerFromButton:)])
            {
                [strongDelegate showDropboxControllerFromButton:barButton];
            }
        }
    }
}

- (void)openLocalBackup:(UIBarButtonItem *)sender
{
    if (nil != self.toolbarManager && nil != sender)
    {
        __strong id <PWESToolbarDelegate> strongDelegate = self.toolbarManager;
        if ([sender isKindOfClass:[UIBarButtonItem class]])
        {
            if ([strongDelegate respondsToSelector:@selector(showLocalBackupControllerFromButton:)])
            {
                [strongDelegate showLocalBackupControllerFromButton:(UIBarButtonItem *) sender];
            }
        }
        else if ([sender isKindOfClass:[UIButton class]])
        {
            UIButton *button = (UIButton *) sender;
            UIBarButtonItem *barButton = [self.barButtons objectAtIndex:button.tag];
            if (nil != barButton &&
                [strongDelegate respondsToSelector:@selector(showLocalBackupControllerFromButton:)])
            {
                [strongDelegate showLocalBackupControllerFromButton:barButton];
            }
        }
    }
}


- (void)showAddMenu:(UIBarButtonItem *)sender
{
    
}

@end
