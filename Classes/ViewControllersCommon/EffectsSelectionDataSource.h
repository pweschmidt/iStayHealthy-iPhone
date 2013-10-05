//
//  EffectsSelectionDataSource.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 05/10/2013.
//
//

#import <Foundation/Foundation.h>

@protocol EffectsSelectionDataSource <NSObject>
- (void)selectedEffectFromList:(NSString *)effect;
@end
