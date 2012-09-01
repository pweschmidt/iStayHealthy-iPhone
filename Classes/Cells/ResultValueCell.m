//
//  ResultValueCell.m
//  iStayHealthy
//
//  Created by peterschmidt on 05/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ResultValueCell.h"

@implementation ResultValueCell
@synthesize inputTitle = _inputTitle;
@synthesize inputValueField = _inputValueField;
@synthesize resultValueDelegate =_resultValueDelegate;
@synthesize inputValueKind = _inputValueKind;
@synthesize colourCodeView = _colourCodeView;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
#ifdef APPDEBUG
    NSLog(@"ResultValueCell initWithStyle");
#endif
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}
- (void)setDelegate:(id)viewControllerDelegate{
    self.resultValueDelegate = viewControllerDelegate;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    textField.textColor = [UIColor blackColor];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self.resultValueDelegate setValueString:textField.text withTag:self.tag];
}

/**
 part of the code snippet - the bit with the Regular Expression - below is from 
 http://stackoverflow.com/questions/1434568/how-to-verify-input-in-uitextfield-i-e-numeric-input
 
 We do a bit of gymnastics here
 First we get the input character range depending on the cell input type, which could be integer, float 
 (with 2 decimal points) and blood pressure (with a \ as separator) 
 the range is checked - and only the characters matching to the expression are passed through
 If passed through the delegate is notified of the new string. This is to enable users to hit the
 save button while entering a field without the expense of tapping 'Done' first
 
 Finally, to ensure that we can convert a float value from continental comma separation to dot separation
 we replace any occurrances of , with .
*/
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{

    NSString *separator = [[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator];
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString *expression = nil;
    if (INTEGERINPUT == self.inputValueKind) {
        expression = @"^([0-9]+)?$";
    }
    else if(FLOATINPUT == self.inputValueKind){
        if ([@"." isEqualToString:separator]) {
            expression = @"^([0-9]{1,3})?(\\.([0-9]{1,2})?)?$";
        }
        else 
        {
            expression = @"^([0-9]{1,3})?(,([0-9]{1,2})?)?$";
        }
    }
    else if(BLOODPRESSUREINPUT == self.inputValueKind){
        expression = @"^([0-9]{1,3})?(\\\([0-9]{1,2})?)?$";
    }

    NSError *error = nil;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression 
                                                                           options:NSRegularExpressionCaseInsensitive 
                                                                             error:&error];
    if (error) {
        return YES;
    }
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:newString
                                                        options:0
                                                          range:NSMakeRange(0, [newString length])];   
    
    
    if (0 < numberOfMatches) {
        NSString *normalisedString = [newString stringByReplacingOccurrencesOfString:@"," withString:@"."];
        [self.resultValueDelegate setValueString:normalisedString withTag:self.tag];
        return YES;
    }
    return NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
