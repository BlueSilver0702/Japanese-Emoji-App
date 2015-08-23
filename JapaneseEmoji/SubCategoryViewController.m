//
//  SubCategoryViewController.m
//  JapaneseEmoji
//
//  Created by Nam Hyok on 5/28/13.
//  Copyright (c) 2013 me. All rights reserved.
//

#import "SubCategoryViewController.h"
#import "DBManager.h"
#import "EmojiListViewController.h"
#import "FavoritesViewController.h"

@interface SubCategoryViewController ()

@end

NSInteger g_selectedIndexOfCell1 = -1, g_selectedIndexOfSection1 = -1;

@implementation SubCategoryViewController
@synthesize mcID, strTitle;

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

    self.navigationController.navigationBar.hidden = YES;
    
    if ([self.strTitle isEqualToString:@"Miscellaneous"]) {
        
        self.label_navTitle.text = @"Misc";
    }else {
        
        self.label_navTitle.text = self.strTitle;
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"app-background.png"]];
    self.table_sc.backgroundView = imageView;
    [imageView release];
    
}

- (void) viewWillAppear:(BOOL)animated {
    
    [self.table_sc reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_img_navBack release];
    [_label_navTitle release];
    [_btn_navFavorites release];
    [_btn_navHome release];
    [_table_sc release];
    [super dealloc];
}
- (IBAction)click_favoritesBtn:(id)sender {
    
    // Go to favorites page.
    FavoritesViewController* favoritesController;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        favoritesController = [[FavoritesViewController alloc] initWithNibName:@"FavoritesViewController" bundle:nil];
    } else {
        
        favoritesController = [[FavoritesViewController alloc] initWithNibName:@"FavoritesViewController_iPad" bundle:nil];
    }
    favoritesController.bSlidePresent = NO;
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:favoritesController];
    [self presentModalViewController:navController animated:YES];
 //   [self.navigationController pushViewController:favoritesController animated:YES];
}

- (IBAction)click_homeBtn:(id)sender {
    
    //[self dismissModalViewControllerAnimated:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Get the array of sub categories.
    NSArray* arrSC = [[DBManager sharedDBManager] getSubCategoriesName:self.mcID];
    return [arrSC count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	return 55;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    UIImageView *fadeIV;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    NSArray* arrSC = [[DBManager sharedDBManager] getSubCategoriesName:self.mcID];
    NSDictionary *itemDic = [arrSC objectAtIndex:indexPath.row];
    NSString *strSGTitle = (NSString*)[itemDic objectForKey:@"scName"];
    cell.textLabel.textColor = [UIColor colorWithRed:0.25f green:0.4f blue:0.49f alpha:1.0f];
    cell.textLabel.text = NSLocalizedString(strSGTitle, nil);
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (indexPath.row == 0) {
        
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCell_select_top_blue"]];
        fadeIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCell_select_top_blue"]];
    }else if(indexPath.row == ([self.table_sc numberOfRowsInSection:0] - 1)){
        
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCell_select_bottom_blue"]];
        fadeIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCell_select_bottom_blue"]];
    }else {
        
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCell_select"]];
        fadeIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCell_select"]];
    }    
    
    if ((indexPath.section == g_selectedIndexOfSection1) && (indexPath.row == g_selectedIndexOfCell1)) {
        
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
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Get the selected sub category's name.
    NSArray* arrScName = [[DBManager sharedDBManager] getSubCategoriesName:self.mcID];
    NSDictionary *itemDic = [arrScName objectAtIndex:indexPath.row];
    NSString *strSGTitle = (NSString*)[itemDic objectForKey:@"scName"];
    
    // Get the selected sub category's ID.
    NSArray* arrScID = [[DBManager sharedDBManager] getSubCategoriesID:self.mcID];
    NSDictionary *idItemDic = [arrScID objectAtIndex:indexPath.row];
    NSInteger scID = [[idItemDic objectForKey:@"scID"] intValue];
    
    EmojiListViewController* emojiListController;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        emojiListController = [[EmojiListViewController alloc] initWithNibName:@"EmojiListViewController" bundle:nil];
    } else {
        
        emojiListController = [[EmojiListViewController alloc] initWithNibName:@"EmojiListViewController_iPad" bundle:nil];
    }
    
    emojiListController.scID = scID;
    emojiListController.strTitle = strSGTitle;
    emojiListController.parentVC = self;
//    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:emojiListController];
//    navController.modalTransitionStyle = UIModalPresentationPageSheet;
//    [self presentModalViewController:navController animated:YES];
    
    g_selectedIndexOfCell1 = indexPath.row;
    g_selectedIndexOfSection1 = indexPath.section;
    [self.navigationController pushViewController:emojiListController animated:YES];
    
}


@end
