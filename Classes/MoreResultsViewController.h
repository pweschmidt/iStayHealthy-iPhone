//
//  MoreResultsViewController.h
//  iStayHealthy
//
//  Created by peterschmidt on 23/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MoreBloodResultsDelegate;

@interface MoreResultsViewController : UITableViewController
@property (nonatomic, weak) id<MoreBloodResultsDelegate>moreBloodResultsDelegate;
@property (nonatomic, strong) NSMutableDictionary *resultsDictionary;
- (void)setResultDelegate:(id)delegate;
- (id)initWithResults:(NSDictionary *)results nibName:(NSString*)nibName;
@end

@protocol MoreBloodResultsDelegate <NSObject>

- (void)setResultString:(NSString *)valueString forTag:(NSInteger)tag;

@end