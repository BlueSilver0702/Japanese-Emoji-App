//
//  CustomPopupView.m
//  JapaneseEmoji
//
//  Created by Nam Hyok on 6/4/13.
//  Copyright (c) 2013 me. All rights reserved.
//

#import "CustomPopupView.h"

@implementation CustomPopupView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id) initWithMessage:(UIView*)_parent title:(NSString *)strTitle message:(NSString*)strMessage dismissAfter:(NSTimeInterval)interval {
    
    if((self = [super init])) {
        
        parent = _parent;
        delay = interval;
        self.label_title.text = strTitle;
        self.label_message.text = strMessage;
        self.iv_background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCell_select_bottom_blue"]];
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        self.frame = CGRectMake(screenRect.size.width/2, screenRect.size.height/2, 200, 100);
        
        
    }
    
    return self;
}

- (void) show {
    
    [parent addSubview:self];
    [self performSelector:@selector(dismissAfterDelay:) withObject:nil afterDelay:1.0f];
}
- (void) dismissAfterDelay:(id)sender {
    
    [UIView beginAnimations:@"fade" context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    self.iv_background.alpha = 0.0f;
    [UIView commitAnimations];
    
    [self removeFromSuperview];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc {
    [_iv_background release];
    [_label_title release];
    [_label_message release];
    [super dealloc];
}
@end
