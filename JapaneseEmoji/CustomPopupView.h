//
//  CustomPopupView.h
//  JapaneseEmoji
//
//  Created by Nam Hyok on 6/4/13.
//  Copyright (c) 2013 me. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomPopupView : UIView {   
    
    UIView      *parent;
    
    CGFloat     delay;
}

@property (retain, nonatomic) IBOutlet UIImageView *iv_background;
@property (retain, nonatomic) IBOutlet UILabel *label_title;
@property (retain, nonatomic) IBOutlet UILabel *label_message;


- (id) initWithMessage:(UIView*)parent title:(NSString *)strTitle message:(NSString*)message dismissAfter:(NSTimeInterval)interval;
- (void) show;
@end
