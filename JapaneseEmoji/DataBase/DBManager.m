//
//  DBManager.m
//  iButtons
//
//  Created by Cai QingRe on 3/19/13.
//  Copyright (c) 2013 JianJinHu. All rights reserved.
//

#import "DBManager.h"
#define kDataBaseName	@"db1.sqlite"

@implementation DBManager

static DBManager *_sharedDBManger = nil;

//================================================================================================================================================================================================
+ (DBManager*) sharedDBManager
{
	if (!_sharedDBManger)
	{
		_sharedDBManger = [[DBManager alloc] init];
	}
	
	return _sharedDBManger;
}

//================================================================================================================================================================================================
+ (void) releaseDBManager
{
	if (_sharedDBManger)
	{
		[_sharedDBManger release];
		_sharedDBManger = nil;
	}
}

//================================================================================================================================================================================================
- (id) init
{
	if ( (self=[super init]) )
	{
		m_sqlManager = [[SQLDatabase alloc] init];
		[m_sqlManager initWithDynamicFile: kDataBaseName];
	}
	
	return self;
}

- (NSArray *) getSubCategoriesName:(NSInteger) mcId {
    
    NSString* strQuery = [NSString stringWithFormat: @"SELECT scName FROM subcategory WHERE mcID = '%d'", mcId];
	return [m_sqlManager lookupAllForSQL: strQuery];

}

- (NSArray *) getSubCategoriesID:(NSInteger) mcId {
    
    NSString* strQuery = [NSString stringWithFormat: @"SELECT scID FROM subcategory WHERE mcID = '%d'", mcId];
	return [m_sqlManager lookupAllForSQL: strQuery];
}

- (NSArray*) getAllEmojis {
    
    NSString* strQuery = [NSString stringWithFormat: @"SELECT emojiName, emojiID FROM EmojiTable"];
	return [m_sqlManager lookupAllForSQL: strQuery];
}

- (NSArray*) getEmojiList:(NSInteger) scId {
    
    NSString* strQuery = [NSString stringWithFormat: @"SELECT emojiName, emojiID FROM EmojiTable WHERE scID = '%d'", scId];
	return [m_sqlManager lookupAllForSQL: strQuery];
}

// Favorite.
- (NSArray*) getFavorites {
    
    NSString* strQuery = [NSString stringWithFormat: @"SELECT emojiID, emojiName FROM FavoritesTable"];
	return [m_sqlManager lookupAllForSQL: strQuery];
}

- (void) addFovorite:(NSInteger)emojiID emojiName:(NSString*)strEmojiName {
    
    NSString* strQuery = [NSString stringWithFormat: @"INSERT INTO 'FavoritesTable'('emojiID','emojiName') VALUES('%d','%@')", emojiID, strEmojiName];
	[m_sqlManager lookupAllForSQL: strQuery];
}

- (void) deleteFovorite:(NSInteger)emojiID {
    
    NSString* strQuery = [NSString stringWithFormat: @"DELETE FROM FavoritesTable WHERE emojiID = '%d'", emojiID];
    [m_sqlManager lookupAllForSQL: strQuery];
}

#pragma mark
#pragma mark - Packs
//================================================================================================================================================================================================
- (NSArray *) getPacks
{
    NSString* strQuery = [NSString stringWithFormat: @"SELECT id, title, purchased, albumtable FROM packs"];
	return [m_sqlManager lookupAllForSQL: strQuery];
}

//================================================================================================================================================================================================
- (NSArray *) getPackWithID:(int)_packID
{
    NSString* strQuery = [NSString stringWithFormat: @"SELECT id, title, purchased, albumtable FROM packs WHERE id = '%d'", _packID];
	return [m_sqlManager lookupAllForSQL: strQuery];
}

#pragma mark
#pragma mark - Albums

//================================================================================================================================================================================================
- (NSArray *) getAlbumsWithPack:(int)_packID
{
    NSArray *_pack = [self getPackWithID:_packID];
    NSDictionary *_cell = [_pack objectAtIndex:0];
    
    NSString *strQuery = [NSString stringWithFormat: @"SELECT id, title, icon, highscore, mashuptable FROM %@", [_cell objectForKey:@"albumtable"]];
    return [m_sqlManager lookupAllForSQL: strQuery];
}

//================================================================================================================================================================================================
- (NSArray *) getAlbumWithPack:(int)_packID andAlbum:(int)_albumID
{
    NSArray *_pack = [self getPackWithID:_packID];
    NSDictionary *_cell = [_pack objectAtIndex:0];
    
    NSString *strQuery = [NSString stringWithFormat: @"SELECT id, title, icon, highscore, mashuptable FROM %@ WHERE id = '%d'", [_cell objectForKey:@"albumtable"], _albumID];
    return [m_sqlManager lookupAllForSQL: strQuery];
}

#pragma mark
#pragma mark - Mashups
//================================================================================================================================================================================================
- (NSArray *) getMashupsWithPack:(int)_packID andAlbum:(int)_albumID;
{
    NSArray *_album = [self getAlbumWithPack:_packID andAlbum:_albumID];
    NSDictionary *_cell = [_album objectAtIndex:0];
    
    NSString *strQuery = [NSString stringWithFormat: @"SELECT id, mashup1, mashup2, mashup3, mashup4, mashup5, mashup6, music, mashup1title, mashup2title, mashup3title, mashup4title, mashup5title, mashup6title FROM %@", [_cell objectForKey:@"mashuptable"]];
    return [m_sqlManager lookupAllForSQL: strQuery];
}

//================================================================================================================================================================================================
- (NSArray *) getMashupWithPack:(int)_packID andAlbum:(int)_albumID andMashup:(int)_mashupID
{
    NSArray *_album = [self getAlbumWithPack:_packID andAlbum:_albumID];
    NSDictionary *_cell = [_album objectAtIndex:0];
    
    NSString *strQuery = [NSString stringWithFormat: @"SELECT id, mashup1, mashup2, mashup3, mashup4, mashup5, mashup6, music, mashup1title, mashup2title, mashup3title, mashup4title, mashup5title, mashup6title FROM %@ WHERE id = '%d'", [_cell objectForKey:@"mashuptable"], _mashupID];
    return [m_sqlManager lookupAllForSQL: strQuery];
}

- (void) setAlbumWithPack:(int)_packID andAlbum:(int)_albumID withHighScore:(int)_highScore
{
    NSArray *_pack = [self getPackWithID:_packID];
    NSDictionary *_cell = [_pack objectAtIndex:0];
    
    NSString *strQuery = [NSString stringWithFormat: @"UPDATE %@ SET highscore = '%d' WHERE id = '%d'", [_cell objectForKey:@"albumtable"], _highScore, _albumID];
    [m_sqlManager lookupAllForSQL: strQuery];
}

//================================================================================================================================================================================================
- (NSArray *) getMashupsNotBelongIntoMashupsWithPack:(int)_packID andAlbum:(int)_albumID andMashups:(NSArray *)_aryMashupIDs
{
    NSArray *_album = [self getAlbumWithPack:_packID andAlbum:_albumID];
    NSDictionary *_cell = [_album objectAtIndex:0];
    
    NSString *strQuery = [NSString stringWithFormat: @"SELECT id, mashup1, mashup2, mashup3, mashup4, mashup5, mashup6, music , mashup1title, mashup2title, mashup3title, mashup4title, mashup5title, mashup6title FROM %@", [_cell objectForKey:@"mashuptable"]];
    
    if ([_aryMashupIDs count] != 0) {
        strQuery = [strQuery stringByAppendingString:@" WHERE "];
        
        for (int i = 0; i < [_aryMashupIDs count]; i++) {
            strQuery = [strQuery stringByAppendingFormat:@"NOT id = '%d'", [[_aryMashupIDs objectAtIndex:i] intValue]];
            
            if (i != [_aryMashupIDs count] - 1) {
                strQuery = [strQuery stringByAppendingFormat:@"AND "];
            }
        }
    }
   
    return [m_sqlManager lookupAllForSQL: strQuery];
}
//================================================================================================================================================================================================
@end