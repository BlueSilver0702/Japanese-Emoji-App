//
//  ViewController.h
//  JapaneseEmoji
//
//  Created by Nam Hyok on 5/28/13.
//  Copyright (c) 2013 me. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainCategoryViewController : UIViewController {
    
    
}

@property (nonatomic, assign) NSInteger selectedIndexOfCell;
@property (nonatomic, assign) NSInteger selectedIndexOfSection;

@property (retain, nonatomic) IBOutlet UIView *uiview_navBar;
@property (retain, nonatomic) IBOutlet UIImageView *image_navBack;
@property (retain, nonatomic) IBOutlet UILabel *label_navTitle;

@property (retain, nonatomic) IBOutlet UITableView *table_mainCategory;

@end
