//
//  EmojiListViewController.h
//  JapaneseEmoji
//
//  Created by Nam Hyok on 5/29/13.
//  Copyright (c) 2013 me. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmojiListViewController : UIViewController {
    
    
}

@property (nonatomic, assign) NSInteger scID;
@property (nonatomic, retain) NSString *strTitle;
@property (nonatomic, retain) UIViewController *parentVC;

/* UI Controls */
// Nav Bar.
@property (retain, nonatomic) IBOutlet UIImageView *img_navBack;
@property (retain, nonatomic) IBOutlet UILabel *label_navTitle;
@property (retain, nonatomic) IBOutlet UIButton *btn_favorites;
@property (retain, nonatomic) IBOutlet UIButton *btn_back;

// Body
@property (retain, nonatomic) IBOutlet UITableView *table_emojis;

// Alert
@property (retain, nonatomic) IBOutlet UIView *uiview_alert;
@property (retain, nonatomic) IBOutlet UILabel *label_title;
@property (retain, nonatomic) IBOutlet UILabel *label_message;




- (IBAction)click_favoritesBtn:(id)sender;
- (IBAction)click_backBtn:(id)sender;

@end
