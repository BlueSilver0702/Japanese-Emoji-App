//
//  FavoritesViewController.m
//  JapaneseEmoji
//
//  Created by Nam Hyok on 5/29/13.
//  Copyright (c) 2013 me. All rights reserved.
//

#import "FavoritesViewController.h"
#import "DBManager.h"
#import "UpdatesTableViewCell.h"
#import "CustomPopupView.h"

#define DeleteTriggerViewTagSinceValue  200000
#define AccessoryViewTagSinceValue      100000

NSInteger g_btnTriggerDel = 0;

@interface FavoritesViewController ()

@end

@implementation FavoritesViewController
@synthesize arrFavorites;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBar.hidden = YES;
    m_editStatus = NO;
    
    self.label_favoriteTitle.text = @"Favorites";
    
    // Load the list of favorites.
    self.arrFavorites = [[DBManager sharedDBManager] getFavorites];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc {
    [_btn_back release];
    [_btn_edit release];
    [_label_favoriteTitle release];
    [_table_favorites release];
    
    [self.arrFavorites release];
    
    [super dealloc];
}
- (IBAction)click_backBtn:(id)sender {
    
    if (self.bSlidePresent) {
        [self.navigationController popViewControllerAnimated:YES];
    }else
        [self dismissModalViewControllerAnimated:YES];
    
}

- (IBAction)click_editBtn:(id)sender {
    
    m_editStatus = !m_editStatus;
    
    // Change the button image to Cancel image.
    if (!m_editStatus) {
        
        [self.btn_edit setImage:[UIImage imageNamed:@"btn_edit"] forState:UIControlStateNormal];
    }else {
        
        [self.btn_edit setImage:[UIImage imageNamed:@"btn_cancel"] forState:UIControlStateNormal];        
    }
    
    // Reload the table.
    [self.table_favorites reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {    
    
    return [self.arrFavorites count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	return 55;
}

#define IPHONE_DEL_BTN_POS_X    262
#define IPHONE_DEL_BTN_POS_Y    15
#define IPHONE_DEL_BTN_WIDTH    50
#define IPHONE_DEL_BTN_HEIGHT   30

#define IPAD_DEL_BTN_POS_X    675
#define IPAD_DEL_BTN_POS_Y    15
#define IPAD_DEL_BTN_WIDTH    50
#define IPAD_DEL_BTN_HEIGHT   30

#define IPHONE_TRI_BTN_POS_X    14
#define IPHONE_TRI_BTN_POS_Y    15
#define IPHONE_TRI_BTN_WIDTH    30
#define IPHONE_TRI_BTN_HEIGHT   30

#define IPAD_TRI_BTN_POS_X    20
#define IPAD_TRI_BTN_POS_Y    15
#define IPAD_TRI_BTN_WIDTH    30
#define IPAD_TRI_BTN_HEIGHT   30



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UpdatesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        NSArray* views;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            
            views = [[NSBundle mainBundle] loadNibNamed:@"UpdatesTableViewCell" owner:nil options:nil];
        } else {
            
            views = [[NSBundle mainBundle] loadNibNamed:@"UpdatesTableViewCell_iPad" owner:nil options:nil];
        }
        
        for (UIView *view in views) {
            
            if([view isKindOfClass:[UITableViewCell class]])
            {
                cell = (UpdatesTableViewCell*)view;
                
                NSDictionary *itemDic = [self.arrFavorites objectAtIndex:indexPath.row];
                NSInteger curEmojiID = [[itemDic objectForKey:@"emojiID"] integerValue];
                NSString *curEmojiName = (NSString*)[itemDic objectForKey:@"emojiName"];
                cell.label_categoryName.textColor = [UIColor colorWithRed:0.17f green:0.17f blue:0.17f alpha:1.0f];
                cell.label_categoryName.text = NSLocalizedString(curEmojiName, nil);
                
                if (m_editStatus) {
                    
                    UIButton *accessoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    accessoryButton.tag = AccessoryViewTagSinceValue + indexPath.row;
                    [accessoryButton setBackgroundImage:[UIImage imageNamed:@"btn_preDelete"] forState:UIControlStateNormal];
                    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                        
                        accessoryButton.frame = CGRectMake(IPHONE_DEL_BTN_POS_X, IPHONE_DEL_BTN_POS_Y, IPHONE_DEL_BTN_WIDTH, IPHONE_DEL_BTN_HEIGHT);
                    } else {
                        
                        accessoryButton.frame = CGRectMake(IPAD_DEL_BTN_POS_X, IPAD_DEL_BTN_POS_Y, IPAD_DEL_BTN_WIDTH, IPAD_DEL_BTN_HEIGHT);
                    }
                    
                    [accessoryButton addTarget:self action:@selector(accessoryButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
                    //accessoryButton.enabled = NO;
                    [cell addSubview:accessoryButton];
                    //[accessoryButton release];
                    
                    UIButton *delTriBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                    delTriBtn.tag = DeleteTriggerViewTagSinceValue + indexPath.row;
                    [delTriBtn setBackgroundImage:[UIImage imageNamed:@"btn_preTriggerDel"] forState:UIControlStateNormal];                    
                    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                        
                        delTriBtn.frame = CGRectMake(IPHONE_TRI_BTN_POS_X, IPHONE_TRI_BTN_POS_Y, IPHONE_TRI_BTN_WIDTH, IPHONE_TRI_BTN_HEIGHT);
                    } else {
                        
                        delTriBtn.frame = CGRectMake(IPAD_TRI_BTN_POS_X, IPAD_TRI_BTN_POS_Y, IPAD_TRI_BTN_WIDTH, IPAD_TRI_BTN_HEIGHT);
                    }
                    
                    [delTriBtn addTarget:self action:@selector(delTriBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
                    [cell addSubview:delTriBtn];
                    //[delTriBtn release];
                }
                
                cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCell_unselect"]];
                cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCell_select"]];

            }
        }
    }  
    
    return cell;
}

-(void) delTriBtnTapped:(id)sender {
    
    
    UIButton *delTrigBtn = (UIButton*)sender;
    NSInteger itemIndex = delTrigBtn.tag - DeleteTriggerViewTagSinceValue;
    NSInteger tagDeleteBtn = AccessoryViewTagSinceValue + itemIndex;
    
    UIButton *delBtn = (UIButton *)[self.view viewWithTag:tagDeleteBtn];
    
    if (!g_btnTriggerDel) {
        
        [delTrigBtn setBackgroundImage:[UIImage imageNamed:@"btn_triggerDel"] forState:UIControlStateNormal];
        [delBtn setBackgroundImage:[UIImage imageNamed:@"btn_delete"] forState:UIControlStateNormal];
        g_btnTriggerDel = 1;
    }else {
        
        [delTrigBtn setBackgroundImage:[UIImage imageNamed:@"btn_preTriggerDel"] forState:UIControlStateNormal];
        [delBtn setBackgroundImage:[UIImage imageNamed:@"btn_preDelete"] forState:UIControlStateNormal];
        g_btnTriggerDel = 0;
    }    
  
    
}

-(void) accessoryButtonTapped:(id)sender {
    
    if (g_btnTriggerDel) {
            
        UIButton *button = (UIButton*)sender;
        NSInteger itemIndex = button.tag - AccessoryViewTagSinceValue;    
    
        NSDictionary *itemDic = [self.arrFavorites objectAtIndex:itemIndex];
        NSInteger curEmojiID = [[itemDic objectForKey:@"emojiID"] integerValue];
    
        [[DBManager sharedDBManager] deleteFovorite:curEmojiID];
    
        // Reload the list of favorites
        self.arrFavorites = [[DBManager sharedDBManager] getFavorites];
        [self.table_favorites reloadData];
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray* listFavorites = [[DBManager sharedDBManager] getFavorites];
    NSDictionary *itemDic = [listFavorites objectAtIndex:indexPath.row];
    NSString *curEmojiName = (NSString*)[itemDic objectForKey:@"emojiName"];
    
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setString:curEmojiName];

    
    CustomPopupView *alertView = [[CustomPopupView alloc] initWithMessage:curEmojiName message:@"Copied!" dismissAfter:2.0f];
    [alertView show];
    [alertView release];
    
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:curEmojiName
//                                                        message:@"Copied!"
//                                                       delegate:nil
//                                              cancelButtonTitle:nil
//                                              otherButtonTitles:@"OK", nil];
//    [alertView show];
}



@end
