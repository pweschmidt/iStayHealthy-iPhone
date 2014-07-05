//
//  SoundSelector.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 05/07/2014.
//
//

#import <Foundation/Foundation.h>

@protocol SoundSelector <NSObject>
- (void)selectedSound:(NSString *)soundName;
@end
