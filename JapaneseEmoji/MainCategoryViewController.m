//
//  ViewController.m
//  JapaneseEmoji
//
//  Created by Nam Hyok on 5/28/13.
//  Copyright (c) 2013 me. All rights reserved.
//

#import "MainCategoryViewController.h"
#import "SubCategoryViewController.h"
#import "Constants.h"
#import "FavoritesViewController.h"
#import "AllEmojisViewController.h"
#import <QuartzCore/QuartzCore.h>

NSInteger g_selectedIndexOfCell = -1, g_selectedIndexOfSection = -1;

@interface MainCategoryViewController ()

@end

@implementation MainCategoryViewController
@synthesize selectedIndexOfCell, selectedIndexOfSection;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationController.navigationBar.hidden = YES;
    
//    CALayer *layer = [self.table_mainCategory layer];
//    [layer setMasksToBounds:YES];
//    [layer setCornerRadius:3.0];
//    [layer setBorderWidth:3.0];
//    [layer setBorderColor:[[UIColor whiteColor] CGColor]];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"app-background.png"]];
    self.table_mainCategory.backgroundView = imageView;
    [imageView release];   
    
    
//    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
//    
//    self.navigationItem.rightBarButtonItem = doneButton;
}

- (void) viewWillAppear:(BOOL)animated {
    
    [self.table_mainCategory reloadData];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @"   ";
}

//- (UIView *) tableview:(UITableView*)tableview viewForHeaderInSection:(NSInteger)section {
//    return view;
//}

- (CGFloat) tableview:(UITableView*)tableview  heightForHeaderInSection:(NSInteger)section  {
    
    return 40;
}

- (CGFloat) tableview:(UITableView*)tableview  heightForFooterInSection:(NSInteger)section  {
    
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	return 55;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(CGFloat) tableView:(UITableView*) tableView heightForHeaderInSection:(NSInteger)section {
    
//    CGFloat space;
//    
//    if (section == 1) {
//        
//        space = 1.0f;
//    }else
//        space = 0.0f;
    
    return 10.0f;
}

-(CGFloat) tableView:(UITableView*) tableView heightForFooterInSection:(NSInteger)section {
    
    return 10.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger numberOfRows;
    if (section == 0) {
        numberOfRows = 2;
    }else {
        numberOfRows = 6;
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    UIImageView *fadeIV;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.section == 0) {
        cell.textLabel.textColor = [UIColor colorWithRed:0.69f green:0.43f blue:0.42f alpha:1.0f];
        
        if (indexPath.row == 0) {
            
            cell.textLabel.text = NSLocalizedString(@"All Emoticons", nil);
            //cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCell_unselect"]];
            cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCell_select_top_red"]];
            fadeIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCell_select_top_red"]];
        }else {
         
            cell.textLabel.text = NSLocalizedString(@"Favorites", nil);
            //cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCell_unselect"]];
            cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCell_select_bottom_red"]];
            fadeIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCell_select_bottom_red"]];
        }
        
        
        
        if ((indexPath.section == g_selectedIndexOfSection) && (indexPath.row == g_selectedIndexOfCell)) {
            
            fadeIV.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
            [cell addSubview:fadeIV];
            
            [UIView beginAnimations:@"fade" context:nil];
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationDuration:0.5];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            fadeIV.alpha = 0.0f;
            [UIView commitAnimations];
            [fadeIV release];
            
        }
       
       
    }else if (indexPath.section == 1) {
        
        cell.textLabel.textColor = [UIColor colorWithRed:0.25f green:0.4f blue:0.49f alpha:1.0f];
        if (indexPath.row == 0) {
            
            cell.textLabel.text = NSLocalizedString(@"Positive Emotions", nil);
            //cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCell_unselect"]];
            cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCell_select_top_blue"]];
            fadeIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCell_select_top_blue"]];
        }else if(indexPath.row == 1){
            
            cell.textLabel.text = NSLocalizedString(@"Neutral Emotions", nil);
            //cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCell_unselect"]];
            cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCell_select"]];
            fadeIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCell_select"]];
        }else if(indexPath.row == 2){
            
            cell.textLabel.text = NSLocalizedString(@"Negative Emotions", nil);
            //cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCell_unselect"]];
            cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCell_select"]];
            fadeIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCell_select"]];
        }else if(indexPath.row == 3) {
            
            cell.textLabel.text = NSLocalizedString(@"Animals", nil);
            //cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCell_unselect"]];
            cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCell_select"]];
            fadeIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCell_select"]];
        }else if(indexPath.row == 4) {
            
            cell.textLabel.text = NSLocalizedString(@"Actions", nil);
            //cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCell_unselect"]];
            cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCell_select"]];
            fadeIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCell_select"]];
        }else {
            
            cell.textLabel.text = NSLocalizedString(@"Miscellaneous", nil);
            //cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCell_unselect"]];
            cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCell_select_bottom_blue"]];
            fadeIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCell_select_bottom_blue"]];
        }
        
        if ((indexPath.section == g_selectedIndexOfSection) && (indexPath.row == g_selectedIndexOfCell)) {
            
            fadeIV.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
            [cell addSubview:fadeIV];
            
            [UIView beginAnimations:@"fade" context:nil];
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationDuration:0.5];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            fadeIV.alpha = 0.0f;
            [UIView commitAnimations];
            [fadeIV release];
            
        }
                
    }    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SubCategoryViewController* scController;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {

        scController = [[SubCategoryViewController alloc] initWithNibName:@"SubCategoryViewController" bundle:nil];
    } else {
        
        scController = [[SubCategoryViewController alloc] initWithNibName:@"SubCategoryViewController_iPad" bundle:nil];
    }   
    
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            
            // All Emoticons.
            // Favorites.
            AllEmojisViewController* allEmojisController;
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                
                allEmojisController = [[AllEmojisViewController alloc] initWithNibName:@"AllEmojisViewController" bundle:nil];
            } else {
                
                allEmojisController = [[AllEmojisViewController alloc] initWithNibName:@"AllEmojisViewController_iPad" bundle:nil];
            }
            
            //UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:allEmojisController];
            //[self presentModalViewController:navController animated:YES];
            
            g_selectedIndexOfCell = indexPath.row;
            g_selectedIndexOfSection = indexPath.section;
            [self.navigationController pushViewController:allEmojisController animated:YES];
            
            return;
            
            
        }else {
            
            // Favorites.
            FavoritesViewController* favoriteController;
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                
                favoriteController = [[FavoritesViewController alloc] initWithNibName:@"FavoritesViewController" bundle:nil];
            } else {
                
                favoriteController = [[FavoritesViewController alloc] initWithNibName:@"FavoritesViewController_iPad" bundle:nil];
            }
            
//            UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:favoriteController];
//            [self presentModalViewController:navController animated:YES];
            favoriteController.bSlidePresent = YES;
            
            g_selectedIndexOfCell = indexPath.row;
            g_selectedIndexOfSection = indexPath.section;
            [self.navigationController pushViewController:favoriteController animated:YES];
            
            return;
            
        }
    }else if (indexPath.section == 1) {
        
        
        if (indexPath.row == 0) {
            
            // Positive Emoticons.
            scController.mcID = MC_ID_POSITIVE;
            scController.strTitle = @"Positive Emotions";
        }else if(indexPath.row == 1){
            
            // Neutral Emoticons.
            scController.mcID = MC_ID_NEUTRAL;
            scController.strTitle = @"Neutral Emotions";
            
        }else {
            
            // Negative Emoticons.
            scController.mcID = MC_ID_NEGATIVE;
            scController.strTitle = @"Negative Emoticons";
        }
    }else {
        
        if (indexPath.row == 0) {
            
            // Animals.
            scController.mcID = MC_ID_ANIMALS;
            scController.strTitle = @"Animals";
        }else if(indexPath.row == 1){
            
            // Actions.
            scController.mcID = MC_ID_ACTIONS;
            scController.strTitle = @"Actions";
        }else {
            
            // Miscellaneous.
            scController.mcID = MC_ID_MISCELLANEOUS;
            scController.strTitle = @"Misc";
        }
    }
    
    //[self transitionFromViewController:self toViewController:scController duration:0.5f options:0 animations:nil completion:nil];
    //[self.navigationController pushViewController:scController animated:YES];
    //UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:scController];
    //[self transitionFromViewController:navController toViewController:scController duration:0.5f options:0 animations:nil completion:nil];
    //navController.modalTransitionStyle = UIModalPresentationPageSheet;
    //[self presentModalViewController:navController animated:NO];
    g_selectedIndexOfCell = indexPath.row;
    g_selectedIndexOfSection = indexPath.section;
    [self.navigationController pushViewController:scController animated:YES];
}


- (void)dealloc {
    [_uiview_navBar release];
    [_image_navBack release];
    [_label_navTitle release];
    [_table_mainCategory release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setUiview_navBar:nil];
    [self setImage_navBack:nil];
    [self setLabel_navTitle:nil];
    [self setTable_mainCategory:nil];
    [super viewDidUnload];
}

#if 0

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


#endif

@end
