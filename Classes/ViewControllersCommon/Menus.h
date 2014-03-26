//
//  Menus.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 23/08/2013.
//
//

#import <Foundation/Foundation.h>

@interface Menus : NSObject
+ (NSArray *)controllerMenu;
+ (NSArray *)hamburgerMenus;
+ (NSArray *)toolbarButtonItems;
+ (NSArray *)addMenus;
+ (NSString *)controllerNameForRowIndexPath:(NSIndexPath *)indexPath
                                ignoreFirst:(BOOL)ignoreFirst;

+ (NSString *)editControllerNameForRowIndexPath:(NSIndexPath *)indexPath
                                    ignoreFirst:(BOOL)ignoreFirst;

+ (NSDictionary *)menuImages;
+ (UIImageView *)buttonImageviewForTitle:(NSString *)title;
@end
