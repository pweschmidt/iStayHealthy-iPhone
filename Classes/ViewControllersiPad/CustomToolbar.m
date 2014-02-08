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

@end

@implementation CustomToolbar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self addCustomBarbuttons];
    }
    return self;
}

- (void)addCustomBarbuttons
{
    NSArray *buttonTypes = [Menus toolbarButtonItems];
    __block NSMutableArray *buttons = [NSMutableArray arrayWithCapacity:buttonTypes.count];
    [buttonTypes enumerateObjectsUsingBlock:^(NSString *title, NSUInteger index, BOOL *stop) {
        UIBarButtonItem *barbutton = nil;
        if ([title isEqualToString:NSLocalizedString(@"Settings", nil)])
        {
            barbutton = [UIBarButtonItem barButtonItemForTitle:title target:self action:@selector(openSettings)];
        }
        else if ([title isEqualToString:NSLocalizedString(@"Backups", nil)])
        {
            barbutton = [UIBarButtonItem barButtonItemForTitle:title target:self action:@selector(openBackup)];
        }
        else if ([title isEqualToString:NSLocalizedString(@"Feedback", nil)])
        {
            barbutton = [UIBarButtonItem barButtonItemForTitle:title target:self action:@selector(openFeedback)];
        }
        else if ([title isEqualToString:NSLocalizedString(@"Email Data", nil)])
        {
            barbutton = [UIBarButtonItem barButtonItemForTitle:title target:self action:@selector(openMailWithAttachment)];
        }
        else if ([title isEqualToString:NSLocalizedString(@"Info", nil)])
        {
            barbutton = [UIBarButtonItem barButtonItemForTitle:title target:self action:@selector(openInfo)];
        }
        if (nil != barbutton)
        {
            [buttons addObject:barbutton];
        }
        
    }];
    [self setItems:buttons];
}
- (void)openFeedback
{
    
}
- (void)openMailWithAttachment
{
    
}
- (void)openSettings
{
    
}
- (void)openInfo
{
    
}
- (void)openBackup
{
    
}

@end
