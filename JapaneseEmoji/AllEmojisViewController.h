//
//  AllEmojisViewController.h
//  JapaneseEmoji
//
//  Created by Nam Hyok on 6/4/13.
//  Copyright (c) 2013 me. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AllEmojisViewController : UIViewController {
    
    NSArray* m_arrEmojis;
}


// UI Properties.
@property (retain, nonatomic) IBOutlet UIButton *btn_navHome;
@property (retain, nonatomic) IBOutlet UIButton *btn_navFavorites;
@property (retain, nonatomic) IBOutlet UITableView *table_emojiList;


// Alert
@property (retain, nonatomic) IBOutlet UIView *uiview_alert;
@property (retain, nonatomic) IBOutlet UILabel *label_title;
@property (retain, nonatomic) IBOutlet UILabel *label_message;

- (IBAction)click_homeBtn:(id)sender;
- (IBAction)click_favoritesBtn:(id)sender;

@end
