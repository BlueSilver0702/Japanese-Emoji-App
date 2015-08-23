//
//  AllEmojisViewController.m
//  JapaneseEmoji
//
//  Created by Nam Hyok on 6/4/13.
//  Copyright (c) 2013 me. All rights reserved.
//

#import "AllEmojisViewController.h"
#import "FavoritesViewController.h"
#import "DBManager.h"
#import "CustomPopupView.h"

@interface AllEmojisViewController ()

@end

#define AccessoryViewTagSinceValue  100000

@implementation AllEmojisViewController

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
    
    self.uiview_alert.hidden = YES;
    self.uiview_alert.alpha = 1.0f;
}

- (void)viewWillAppear:(BOOL)animated {
    
    m_arrEmojis = [[[DBManager sharedDBManager] getAllEmojis] retain];
    [self.table_emojiList reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    if (m_arrEmojis) {
        [m_arrEmojis release];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_btn_navHome release];
    [_btn_navFavorites release];
    [_table_emojiList release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setBtn_navHome:nil];
    [self setBtn_navFavorites:nil];
    [self setTable_emojiList:nil];
    [super viewDidUnload];
}


- (IBAction)click_homeBtn:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

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
    //[self.navigationController pushViewController:favoritesController animated:YES];
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
    return [m_arrEmojis count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }    
    
    NSDictionary *itemDic = [m_arrEmojis objectAtIndex:indexPath.row];
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
        
    NSDictionary *itemDic = [m_arrEmojis objectAtIndex:itemIndex];
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
        [self performSelector:@selector(dismissAlert:) withObject:nil afterDelay:0.5f];    }
    
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
        
    NSDictionary *itemDic = [m_arrEmojis objectAtIndex:indexPath.row];
    NSString *curEmojiName = (NSString*)[itemDic objectForKey:@"emojiName"];
    
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setString:curEmojiName];
    
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



@end
