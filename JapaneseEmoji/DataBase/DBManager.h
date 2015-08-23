//
//  DBManager.h
//  iButtons
//
//  Created by Cai QingRe on 3/19/13.
//  Copyright (c) 2013 JianJinHu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLDatabase.h"

@interface DBManager : NSObject
{
    SQLDatabase*	m_sqlManager;
}

+ (DBManager*) sharedDBManager;
+ (void) releaseDBManager;

- (id) init;

- (NSArray *) getSubCategoriesName:(NSInteger) mcId;
- (NSArray *) getSubCategoriesID:(NSInteger) mcId;

- (NSArray*) getAllEmojis;
- (NSArray*) getEmojiList:(NSInteger) scId;

// Favorites
- (NSArray*) getFavorites;
- (void) addFovorite:(NSInteger)emojiID emojiName:(NSString*)strEmojiName;
- (void) deleteFovorite:(NSInteger)emojiID;

- (NSArray *) getPacks;
- (NSArray *) getPackWithID:(int)_packID;

- (NSArray *) getAlbumsWithPack:(int)_packID;
- (NSArray *) getAlbumWithPack:(int)_packID andAlbum:(int)_albumID;

- (NSArray *) getMashupsWithPack:(int)_packID andAlbum:(int)_albumID;
- (NSArray *) getMashupWithPack:(int)_packID andAlbum:(int)_albumID andMashup:(int)_mashupID;

- (NSArray *) getMashupsNotBelongIntoMashupsWithPack:(int)_packID andAlbum:(int)_albumID andMashups:(NSArray *)_aryMashupIDs;

- (void) setAlbumWithPack:(int)_packID andAlbum:(int)_albumID withHighScore:(int)_highScore;
@end