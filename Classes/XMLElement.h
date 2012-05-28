//
//  XMLElement.h
//  iStayHealthy
//
//  Created by peterschmidt on 13/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMLElement : NSObject{
    NSString *name;
    NSString *value;
    NSMutableArray *attributes;
    NSMutableArray *childElements;
    int nodeLevel;    
}
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) NSMutableArray *attributes;
@property (nonatomic, strong) NSMutableArray *childElements;
- (id)initWithName:(NSString *)elementName;
- (void)setNodeLevel:(int)level;
- (void)addChild:(XMLElement *)element;
- (void)addAttribute:(NSString *)withName andValue:(NSString *)withValue;
- (void)addValue:(NSString *)valueText;
- (NSMutableString *)toString;
- (NSMutableString *)tabs;
- (NSString *)elementUID;
- (NSString *)attributeValue:(NSString *)forKey;
@end
