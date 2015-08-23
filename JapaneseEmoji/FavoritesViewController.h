//
//  FavoritesViewController.h
//  JapaneseEmoji
//
//  Created by Nam Hyok on 5/29/13.
//  Copyright (c) 2013 me. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavoritesViewController : UIViewController {
    
    bool m_editStatus;
    
}

@property (nonatomic, retain) NSArray *arrFavorites;
@property (nonatomic, assign) BOOL bSlidePresent;

// UI Controlls.
@property (retain, nonatomic) IBOutlet UIButton *btn_back;
@property (retain, nonatomic) IBOutlet UIButton *btn_edit;
@property (retain, nonatomic) IBOutlet UILabel *label_favoriteTitle;
@property (retain, nonatomic) IBOutlet UITableView *table_favorites;

- (IBAction)click_backBtn:(id)sender;
- (IBAction)click_editBtn:(id)sender;

@end
