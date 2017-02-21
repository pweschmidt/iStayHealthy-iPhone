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
#import "iStayHealthy-Swift.h"

@interface CustomToolbar ()
{
    CGRect popUpFrame;
}
@property (nonatomic, strong) NSMutableArray *barButtons;
@property (nonatomic, weak) id <PWESToolbarDelegate> toolbarManager;
@property (nonatomic, strong) UIViewController *controller;
@end

@implementation CustomToolbar

- (instancetype)initWithToolbarManager:(id<PWESToolbarDelegate>)toolbarManager
                  presentingController:(UIViewController *)controller
{
    self = [super init];
    if (nil != self)
    {
        _toolbarManager = toolbarManager;
        _controller = controller;
        [self addCustomBarbuttons];
    }
    return self;
}

- (void)addCustomBarbuttons
{
    NSArray *buttonTypes = [Menus toolbarButtonItems];

    self.barButtons = [NSMutableArray array];
    UIBarButtonItem *initialSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];

    __block NSMutableArray *buttons = [NSMutableArray arrayWithCapacity:buttonTypes.count];

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
         else if ([title isEqualToString:NSLocalizedString(@"Email Data", nil)])
         {
             barbutton = [UIBarButtonItem barButtonItemForTitle:title target:self action:@selector(showFeedbackController:) buttonTag:index];
         }
         else if ([title isEqualToString:NSLocalizedString(@"Info", nil)])
         {
             barbutton = [UIBarButtonItem barButtonItemForTitle:title target:self action:@selector(openInfo:) buttonTag:index];
         }

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

}

- (void)showFeedbackController:(id)sender
{
    if (nil != self.toolbarManager && nil != sender)
    {
        __strong id <PWESToolbarDelegate> strongDelegate = self.toolbarManager;
        if ([sender isKindOfClass:[UIBarButtonItem class]])
        {
            if ([strongDelegate respondsToSelector:@selector(showMailSelectionControllerFromButton:)])
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

//- (void)openFeedback
//{
//    if (nil != self.toolbarManager)
//    {
//        __strong id <PWESToolbarDelegate> strongDelegate = self.toolbarManager;
//        if ([strongDelegate respondsToSelector:@selector(showMailControllerHasAttachment:)])
//        {
//            [strongDelegate showMailControllerHasAttachment:NO];
//        }
//    }
//}
//
//
//- (void)openMailWithAttachment
//{
//    PWESAlertAction *cancel = [[PWESAlertAction alloc] initWithAlertButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleCancel action:nil];
//    PWESAlertAction *yes = [[PWESAlertAction alloc] initWithAlertButtonTitle:NSLocalizedString(@"Yes", nil) style:UIAlertActionStyleDefault action:^{
//        if (nil != self.toolbarManager)
//        {
//            __strong id <PWESToolbarDelegate> strongDelegate = self.toolbarManager;
//            if ([strongDelegate respondsToSelector:@selector(showMailControllerHasAttachment:)])
//            {
//                [strongDelegate showMailControllerHasAttachment:NO];
//            }
//        }
//    }];
//    [PWESAlertHandler.alertHandler showAlertView:NSLocalizedString(@"Send data?", nil) message:NSLocalizedString(@"You are about to email data. Click Yes if you want to continue.", nil) presentingController:self.controller actions:@[yes, cancel]];
//    
//}


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

@end
