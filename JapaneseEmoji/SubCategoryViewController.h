//
//  SubCategoryViewController.h
//  JapaneseEmoji
//
//  Created by Nam Hyok on 5/28/13.
//  Copyright (c) 2013 me. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubCategoryViewController : UIViewController {
    
    NSArray *m_arrSubCategory;
}

@property (nonatomic, assign) NSInteger mcID;
@property (nonatomic, retain) NSString *strTitle;

/* UI controls */
// Nav Bar controls.
@property (retain, nonatomic) IBOutlet UIImageView *img_navBack;
@property (retain, nonatomic) IBOutlet UILabel *label_navTitle;
@property (retain, nonatomic) IBOutlet UIButton *btn_navFavorites;
@property (retain, nonatomic) IBOutlet UIButton *btn_navHome;
@property (retain, nonatomic) IBOutlet UITableView *table_sc;


- (IBAction)click_favoritesBtn:(id)sender;
- (IBAction)click_homeBtn:(id)sender;

@end
