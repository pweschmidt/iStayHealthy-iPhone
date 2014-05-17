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
	    else if ([title isEqualToString:NSLocalizedString(@"Feedback", nil)])
	    {
	        barbutton = [UIBarButtonItem barButtonItemForTitle:title target:self action:@selector(openFeedback) buttonTag:index];
		}
	    else if ([title isEqualToString:NSLocalizedString(@"Email Data", nil)])
	    {
	        barbutton = [UIBarButtonItem barButtonItemForTitle:title target:self action:@selector(openMailWithAttachment) buttonTag:index];
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
	[self setItems:buttons];
}

- (void)openFeedback
{
	if (nil != self.customToolbarDelegate)
	{
		__strong id <PWESToolbarDelegate> strongDelegate = self.customToolbarDelegate;
		if ([strongDelegate respondsToSelector:@selector(showMailControllerHasAttachment:)])
		{
			[strongDelegate showMailControllerHasAttachment:NO];
		}
	}
}

- (void)openMailWithAttachment
{
	if (nil != self.customToolbarDelegate)
	{
		__strong id <PWESToolbarDelegate> strongDelegate = self.customToolbarDelegate;
		if ([strongDelegate respondsToSelector:@selector(showMailControllerHasAttachment:)])
		{
			[strongDelegate showMailControllerHasAttachment:YES];
		}
	}
}

- (void)openSettings:(id)sender
{
	if (nil != self.customToolbarDelegate && nil != sender)
	{
		__strong id <PWESToolbarDelegate> strongDelegate = self.customToolbarDelegate;
		if ([sender isKindOfClass:[UIBarButtonItem class]])
		{
			if ([strongDelegate respondsToSelector:@selector(showPasswordControllerFromButton:)])
			{
				[strongDelegate showPasswordControllerFromButton:(UIBarButtonItem *)sender];
			}
		}
		else if ([sender isKindOfClass:[UIButton class]])
		{
			UIButton *button = (UIButton *)sender;
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
	if (nil != self.customToolbarDelegate && nil != sender)
	{
		__strong id <PWESToolbarDelegate> strongDelegate = self.customToolbarDelegate;
		if ([sender isKindOfClass:[UIBarButtonItem class]])
		{
			if ([strongDelegate respondsToSelector:@selector(showPasswordControllerFromButton:)])
			{
				[strongDelegate showInfoControllerFromButton:(UIBarButtonItem *)sender];
			}
		}
		else if ([sender isKindOfClass:[UIButton class]])
		{
			UIButton *button = (UIButton *)sender;
			UIBarButtonItem *barButton = [self.barButtons objectAtIndex:button.tag];
			if ([strongDelegate respondsToSelector:@selector(showPasswordControllerFromButton:)])
			{
				[strongDelegate showInfoControllerFromButton:barButton];
			}
		}
	}
}

- (void)openBackup:(UIBarButtonItem *)sender
{
	if (nil != self.customToolbarDelegate && nil != sender)
	{
		__strong id <PWESToolbarDelegate> strongDelegate = self.customToolbarDelegate;
		if ([sender isKindOfClass:[UIBarButtonItem class]])
		{
			if ([strongDelegate respondsToSelector:@selector(showPasswordControllerFromButton:)])
			{
				[strongDelegate showDropboxControllerFromButton:(UIBarButtonItem *)sender];
			}
		}
		else if ([sender isKindOfClass:[UIButton class]])
		{
			UIButton *button = (UIButton *)sender;
			UIBarButtonItem *barButton = [self.barButtons objectAtIndex:button.tag];
			if ([strongDelegate respondsToSelector:@selector(showPasswordControllerFromButton:)])
			{
				[strongDelegate showDropboxControllerFromButton:barButton];
			}
		}
	}
}

@end
