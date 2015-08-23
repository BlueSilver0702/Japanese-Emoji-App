//
//  EmojiListViewController.m
//  JapaneseEmoji
//
//  Created by Nam Hyok on 5/29/13.
//  Copyright (c) 2013 me. All rights reserved.
//

#import "EmojiListViewController.h"
#import "FavoritesViewController.h"
#import "DBManager.h"
#import "CustomPopupView.h"

#define AccessoryViewTagSinceValue  100000

@interface EmojiListViewController ()

@end

@implementation EmojiListViewController
@synthesize scID, strTitle, parentVC;

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
    
    if ([self.strTitle isEqualToString:@"Miscellaneous"]) {
        
        self.label_navTitle.text = @"Misc";
    }else if ([self.strTitle isEqualToString:@"Hello and Goodbye"]) {
        
        self.label_navTitle.text = @"Hello";
    }else if ([self.strTitle isEqualToString:@"Fish and Sea Creatures"]) {
        
        self.label_navTitle.text = @"Fish";
    }else if ([self.strTitle isEqualToString:@"Shy or Embarrassed"]) {
        
        self.label_navTitle.text = @"Shy";
    }else if ([self.strTitle isEqualToString:@"Happy or Joyful"]) {
        
        self.label_navTitle.text = @"Happy";
    }else if ([self.strTitle isEqualToString:@"Infatuation or Love"]) {
        
        self.label_navTitle.text = @"Love";
    }else {
        
        self.label_navTitle.text = self.strTitle;
    }
    
   self.uiview_alert.hidden = YES;
    self.uiview_alert.alpha = 1.0f;

}
- (void)viewWillAppear:(BOOL)animated {
    
    [self.table_emojis reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_img_navBack release];
    [_label_navTitle release];
    [_btn_favorites release];
    [_btn_back release];
    [_table_emojis release];
    [_uiview_alert release];
    [_label_title release];
    [_label_message release];
    [super dealloc];
}

/******************************************** UI Actions *************************************************************/
- (IBAction)click_favoritesBtn:(id)sender {
    
    FavoritesViewController* favoritesController;    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        favoritesController = [[FavoritesViewController alloc] initWithNibName:@"FavoritesViewController" bundle:nil];
    } else {
        
        favoritesController = [[FavoritesViewController alloc] initWithNibName:@"FavoritesViewController_iPad" bundle:nil];
    }
    favoritesController.bSlidePresent = NO;
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:favoritesController];    
    [self presentModalViewController:navController animated:YES];
//    [self.navigationController pushViewController:favoritesController animated:YES];
}

- (IBAction)click_backBtn:(id)sender {
    
    //[self dismissModalViewControllerAnimated:YES];
    [self.parentVC.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	return 55;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Get the array of emojis related to the specified sub categories.
    NSArray* arrEmojis = [[DBManager sharedDBManager] getEmojiList:self.scID];
    return [arrEmojis count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    NSArray* arrEmojis = [[DBManager sharedDBManager] getEmojiList:self.scID];
    NSDictionary *itemDic = [arrEmojis objectAtIndex:indexPath.row];
    NSInteger curEmojiID = [[itemDic objectForKey:@"emojiID"] integerValue];
    NSString *curEmojiName = (NSString*)[itemDic objectForKey:@"emojiName"];
    cell.textLabel.textColor = [UIColor colorWithRed:0.17f green:0.17f blue:0.17f alpha:1.0f];
    cell.textLabel.text = NSLocalizedString(curEmojiName, nil);
    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    UIButton *accessoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    accessoryButton.tag = AccessoryViewTagSinceValue + indexPath.row;
    
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCell_unselect"]];
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCell_select"]];
    
    NSArray *arrFavorites = [[DBManager sharedDBManager] getFavorites];
    if (([arrFavorites count] != 0)) {
        for (int i = 0; i < [arrFavorites count]; i++) {
            NSDictionary *favoriteItemDic = [arrFavorites objectAtIndex:i];
            NSInteger favoriteEmojiID = [[favoriteItemDic objectForKey:@"emojiID"] integerValue];
            if (curEmojiID == favoriteEmojiID) {
                [accessoryButton setBackgroundImage:[UIImage imageNamed:@"btn_addToFavorite"] forState:UIControlStateNormal];
                break;
            }
            if (i == ([arrFavorites count] - 1 )) {
                [accessoryButton setBackgroundImage:[UIImage imageNamed:@"btn_addToFavoriteHL"] forState:UIControlStateNormal];
            }
        }
        if (0 == ([arrFavorites count])) {
            [accessoryButton setBackgroundImage:[UIImage imageNamed:@"btn_addToFavoriteHL"] forState:UIControlStateNormal];
        }
    }else
        [accessoryButton setBackgroundImage:[UIImage imageNamed:@"btn_addToFavoriteHL"] forState:UIControlStateNormal];
    
    
    accessoryButton.frame = CGRectMake(0, 0, 50, 50);
    [accessoryButton addTarget:self action:@selector(accessoryButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView = accessoryButton;
    
    return cell;
}

-(void) accessoryButtonTapped:(id)sender {
    
    UIButton *button = (UIButton*)sender;
    NSInteger itemIndex = button.tag - AccessoryViewTagSinceValue;
    Boolean bIsAlreadyFavorite = NO;
    
    NSArray* arrEmojis = [[DBManager sharedDBManager] getEmojiList:self.scID];
    NSDictionary *itemDic = [arrEmojis objectAtIndex:itemIndex];
    NSInteger selectedEmojiID = [[itemDic objectForKey:@"emojiID"] integerValue];
    NSString *selectedEmojiName = (NSString*)[itemDic objectForKey:@"emojiName"];
    
    NSArray *arrFavorites = [[DBManager sharedDBManager] getFavorites];
    if (([arrFavorites count] != 0))  {
        for (int i = 0; i < [arrFavorites count]; i++) {
            NSDictionary *favoriteItemDic = [arrFavorites objectAtIndex:i];
            NSInteger favoriteEmojiID = [[favoriteItemDic objectForKey:@"emojiID"] integerValue];
            if (selectedEmojiID == favoriteEmojiID) {
                bIsAlreadyFavorite = YES;
                
                // Remove this emoji from the favorite list.
                [[DBManager sharedDBManager] deleteFovorite:selectedEmojiID];
                
                break;
            }
        }
    }
    
    if (bIsAlreadyFavorite) { // This emoji was already in the favorite list.
        
        [button setBackgroundImage:[UIImage imageNamed:@"btn_addToFavoriteHL"] forState:UIControlStateNormal];
    }else {
        
        // Add this emoji to the favorite list.
        [[DBManager sharedDBManager] addFovorite:selectedEmojiID emojiName:selectedEmojiName];
        
        [button setBackgroundImage:[UIImage imageNamed:@"btn_addToFavorite"] forState:UIControlStateNormal]; 
       
        
        self.label_title.text = selectedEmojiName;
        self.label_message.text = @"Added to Favorites!";
        
        self.uiview_alert.hidden = NO;
        [self performSelector:@selector(dismissAlert:) withObject:nil afterDelay:0.5f];
        
    }   
    
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray* arrEmojis = [[DBManager sharedDBManager] getEmojiList:self.scID];
    NSDictionary *itemDic = [arrEmojis objectAtIndex:indexPath.row];
    NSString *curEmojiName = (NSString*)[itemDic objectForKey:@"emojiName"];
    
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setString:curEmojiName];
    
    //CustomPopupView *alertView = [[CustomPopupView alloc] initWithMessage:self.view title:curEmojiName message:@"Copied!" dismissAfter:0.0f];
    //[alertView show];
    //[alertView release];
    
    self.label_title.text = curEmojiName;
    self.label_message.text = @"Copied!";   
    
    self.uiview_alert.hidden = NO;    
    [self performSelector:@selector(dismissAlert:) withObject:nil afterDelay:0.5f];    
    
}

- (void) dismissAlert:(id) sender {
    
    [UIView beginAnimations:@"fadeOut" context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    self.uiview_alert.alpha = 0.0f;
    [UIView commitAnimations];
    
    [self performSelector:@selector(hideAlert:) withObject:nil afterDelay:1.0f];    
}

- (void) hideAlert:(id) sender {
 
    self.uiview_alert.hidden = YES;
    self.uiview_alert.alpha = 1.0f;
}


- (void)viewDidUnload {
    [self setUiview_alert:nil];
    [self setLabel_title:nil];
    [self setLabel_message:nil];
    [super viewDidUnload];
}
@end
