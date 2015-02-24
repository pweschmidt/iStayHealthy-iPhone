//
//  PWESToolbarDelegate.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 06/04/2014.
//
//

#import <Foundation/Foundation.h>

@protocol PWESToolbarDelegate <NSObject>
- (void)showPasswordControllerFromButton:(UIBarButtonItem *)button;
- (void)showMailControllerHasAttachment:(BOOL)hasAttachment;
- (void)showDropboxControllerFromButton:(UIBarButtonItem *)button;
- (void)showInfoControllerFromButton:(UIBarButtonItem *)button;
- (void)showHelpControllerFromButton:(UIBarButtonItem *)button;
- (void)showLocalBackupControllerFromButton:(UIBarButtonItem *)button;
- (void)showMailSelectionControllerFromButton:(UIBarButtonItem *)button;
@end
