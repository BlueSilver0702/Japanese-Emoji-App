//
//  SQLDatabase.m
//  Version 1.1
//
//  Created by Morimuraseiichi on 9/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SQLDatabase.h"

@implementation SQLDatabase

@synthesize delegate;
@synthesize dbh;
@synthesize dynamic;

// Two ways to init: one if you're just SELECTing from a database, one if you're UPDATing
// and or INSERTing
//================================================================================================================================================================================================
- (id)initWithFile:(NSString *)dbFile {
	if ((self=[super init])) {
	
		NSString *paths = [[NSBundle mainBundle] resourcePath];
		NSString *path = [paths stringByAppendingPathComponent:dbFile];
		
		NSLog(@"pass = %@", path);
		int result = sqlite3_open([path UTF8String], &dbh);
		NSAssert1(SQLITE_OK == result, NSLocalizedStringFromTable(@"Unable to open the sqlite database (%@).", @"Database", @""), [NSString stringWithUTF8String:sqlite3_errmsg(dbh)]);	
		self.dynamic = NO;
	}
	
	return self;	
}

//================================================================================================================================================================================================
- (id)initWithDynamicFile:(NSString *)dbFile
{
	if ((self=[super init]))
	{		
		NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *docDir = [docPaths objectAtIndex:0];
		NSString *docPath = [docDir stringByAppendingPathComponent:dbFile];
		
		NSFileManager *fileManager = [NSFileManager defaultManager];
		
		if (![fileManager fileExistsAtPath:docPath]) {

			NSString *origPaths = [[NSBundle mainBundle] resourcePath];
			NSString *origPath = [origPaths stringByAppendingPathComponent:dbFile];
		
			NSError *error;
			int success = [fileManager copyItemAtPath:origPath toPath:docPath error:&error];			
			NSAssert1(success,@"Failed to copy database into dynamic location",error);
		}
		int result = sqlite3_open([docPath UTF8String], &dbh);
		NSAssert1(SQLITE_OK == result, NSLocalizedStringFromTable(@"Unable to open the sqlite database (%@).", @"Database", @""), [NSString stringWithUTF8String:sqlite3_errmsg(dbh)]);	
		self.dynamic = YES;
	}
	
	return self;	
}
//================================================================================================================================================================================================
// Users should never need to call prepare

- (sqlite3_stmt *)prepare:(NSString *)sql {
	
	const char *utfsql = [sql UTF8String];
	
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare([self dbh],utfsql,-1,&statement,NULL) == SQLITE_OK) {
		return statement;
	} else {
		return 0;
	}
}

// Three ways to lookup results: for a variable number of responses, for a full row
// of responses, or for a singular bit of data
//================================================================================================================================================================================================
- (NSArray *)lookupAllForSQL:(NSString *)sql {
	sqlite3_stmt *statement;
	id result;
	NSMutableArray *thisArray = [NSMutableArray arrayWithCapacity:4];
	if ( (statement = [self prepare:sql]) ) {
		while (sqlite3_step(statement) == SQLITE_ROW) {	
			NSMutableDictionary *thisDict = [NSMutableDictionary dictionaryWithCapacity:4];
			for (int i = 0 ; i < sqlite3_column_count(statement) ; i++)
            {
				if (sqlite3_column_decltype(statement,i) != NULL &&
					strcasecmp(sqlite3_column_decltype(statement,i),"Boolean") == 0)
                {
					result = [NSNumber numberWithBool:(BOOL)sqlite3_column_int(statement,i)];
				} else if (sqlite3_column_type(statement, i) == SQLITE_TEXT)
                {
					result = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,i)];
				}
                else if (sqlite3_column_type(statement,i) == SQLITE_INTEGER)
                {
					result = [NSNumber numberWithInt:(int)sqlite3_column_int(statement,i)];
				}
                else if (sqlite3_column_type(statement,i) == SQLITE_FLOAT)
                {
					result = [NSNumber numberWithFloat:(float)sqlite3_column_double(statement,i)];					
				}
				if (result) {
					[thisDict setObject:result
								 forKey:[NSString stringWithUTF8String:sqlite3_column_name(statement,i)]];
				}
			}
			[thisArray addObject:[NSDictionary dictionaryWithDictionary:thisDict]];
		}
	}
	sqlite3_finalize(statement);
	return thisArray;
}

//================================================================================================================================================================================================
- (NSDictionary *)lookupRowForSQL:(NSString *)sql
{
	sqlite3_stmt *statement;
	id result;
	NSMutableDictionary *thisDict = [NSMutableDictionary dictionaryWithCapacity:4];
	if( (statement = [self prepare:sql]) ) {
		if (sqlite3_step(statement) == SQLITE_ROW) {	
			for (int i = 0 ; i < sqlite3_column_count(statement) ; i++) {
				if (strcasecmp(sqlite3_column_decltype(statement,i),"Boolean") == 0) {
					result = [NSNumber numberWithBool:(BOOL)sqlite3_column_int(statement,i)];
				} else if (sqlite3_column_type(statement, i) == SQLITE_TEXT) {
					result = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,i)];
				} else if (sqlite3_column_type(statement,i) == SQLITE_INTEGER) {
					result = [NSNumber numberWithInt:(int)sqlite3_column_int(statement,i)];
				} else if (sqlite3_column_type(statement,i) == SQLITE_FLOAT) {
					result = [NSNumber numberWithFloat:(float)sqlite3_column_double(statement,i)];					
				} else {
					result = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,i)];
				}
				if (result) {
					[thisDict setObject:result
								 forKey:[NSString stringWithUTF8String:sqlite3_column_name(statement,i)]];
				}
			}
		}
	}
	sqlite3_finalize(statement);
	return thisDict;
}

//================================================================================================================================================================================================
- (id)lookupColForSQL:(NSString *)sql
{
	sqlite3_stmt *statement;
	id result;
	if( (statement = [self prepare:sql]) ) {
		if (sqlite3_step(statement) == SQLITE_ROW) {		
			if (strcasecmp(sqlite3_column_decltype(statement,0),"Boolean") == 0) {
				result = [NSNumber numberWithBool:(BOOL)sqlite3_column_int(statement,0)];
			} else if (sqlite3_column_type(statement, 0) == SQLITE_TEXT) {
				result = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,0)];
			} else if (sqlite3_column_type(statement,0) == SQLITE_INTEGER) {
				result = [NSNumber numberWithInt:(int)sqlite3_column_int(statement,0)];
			} else if (sqlite3_column_type(statement,0) == SQLITE_FLOAT) {
				result = [NSNumber numberWithDouble:(double)sqlite3_column_double(statement,0)];					
			} else {
				result = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,0)];
			}
		}
	}
	sqlite3_finalize(statement);
	return result;
	
}

// Simple use of COUNTS, MAX, etc.
//================================================================================================================================================================================================
- (int)lookupCountWhere:(NSString *)where forTable:(NSString *)table
{

	int tableCount = 0;
	NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ WHERE %@",
					 table,where];    	
	sqlite3_stmt *statement;

	if( (statement = [self prepare:sql]) ) {
		if (sqlite3_step(statement) == SQLITE_ROW) {		
			tableCount = sqlite3_column_int(statement,0);
		}
	}
	sqlite3_finalize(statement);
	return tableCount;
				
}
//================================================================================================================================================================================================
- (int)lookupMax:(NSString *)key Where:(NSString *)where forTable:(NSString *)table
{
	
	int tableMax = 0;
	NSString *sql = [NSString stringWithFormat:@"SELECT MAX(%@) FROM %@ WHERE %@",
					 key,table,where];    	
	sqlite3_stmt *statement;
	if( (statement = [self prepare:sql]) ) {
		if (sqlite3_step(statement) == SQLITE_ROW) {		
			tableMax = sqlite3_column_int(statement,0);
		}
	}
	sqlite3_finalize(statement);
	return tableMax;
	
}
//================================================================================================================================================================================================
- (int)lookupSum:(NSString *)key Where:(NSString *)where forTable:(NSString *)table
{
	
	int tableSum = 0;
	NSString *sql = [NSString stringWithFormat:@"SELECT SUM(%@) FROM %@ WHERE %@",
					 key,table,where];    	
	sqlite3_stmt *statement;
	if( (statement = [self prepare:sql]) ) {
		if (sqlite3_step(statement) == SQLITE_ROW) {		
			tableSum = sqlite3_column_int(statement,0);
		}
	}
	sqlite3_finalize(statement);
	return tableSum;
	
}

// INSERTing and UPDATing
//================================================================================================================================================================================================
- (void)insertArray:(NSArray *)dbData forTable:(NSString *)table
{

	for(UInt32 i=0; i<[dbData count]; i++)
	{
		NSDictionary *dict=[dbData objectAtIndex:i];
		NSMutableString *sql = [NSMutableString stringWithCapacity:16];
		[sql appendFormat:@"INSERT INTO %@ (",table];
		
		NSArray *dataKeys = [dict allKeys];
		for (UInt32 i = 0 ; i < [dataKeys count] ; i++) {
			[sql appendFormat:@"%@",[dataKeys objectAtIndex:i]];
			if (i + 1 < [dataKeys count]) {
				[sql appendFormat:@", "];
			}
		}
		
		[sql appendFormat:@") VALUES("];
		for (UInt32 i = 0 ; i < [dataKeys count] ; i++) {
			if ([[dict objectForKey:[dataKeys objectAtIndex:i]] intValue]) {
				[sql appendFormat:@"%@",[dict objectForKey:[dataKeys objectAtIndex:i]]];
			} else {
				[sql appendFormat:@"'%@'",[dict objectForKey:[dataKeys objectAtIndex:i]]];
			}
			if (i + 1 < [dict count]) {
				[sql appendFormat:@", "];
			}
		}
		
		[sql appendFormat:@")"];
		[self runDynamicSQL:sql forTable:table];
	}
}
//================================================================================================================================================================================================
- (void)insertDictionary:(NSDictionary *)dbData forTable:(NSString *)table
{
	NSMutableString *sql = [NSMutableString stringWithCapacity:16];
	[sql appendFormat:@"INSERT INTO %@ (",table];

	NSArray *dataKeys = [dbData allKeys];
	for (UInt32 i = 0 ; i < [dataKeys count] ; i++) {
		[sql appendFormat:@"%@",[dataKeys objectAtIndex:i]];
		if (i + 1 < [dbData count]) {
			[sql appendFormat:@", "];
		}
	}

	[sql appendFormat:@") VALUES("];
	for (UInt32 i = 0 ; i < [dataKeys count] ; i++) {
		[sql appendFormat:@"'%@'",[dbData objectForKey:[dataKeys objectAtIndex:i]]];
		if (i + 1 < [dbData count]) {
			[sql appendFormat:@", "];
		}
	}

	[sql appendFormat:@")"];
	[self runDynamicSQL:sql forTable:table];
}

//================================================================================================================================================================================================
- (void)updateArray:(NSArray *)dbData forTable:(NSString *)table
{
	[self updateArray:dbData forTable:table where:NULL];
}

//================================================================================================================================================================================================
- (void)updateArray:(NSArray *)dbData forTable:(NSString *)table where:(NSString *)where
{
	NSMutableString *sql = [NSMutableString stringWithCapacity:16];
	[sql appendFormat:@"UPDATE %@ SET ",table];
	
	for (UInt32 i = 0 ; i < [dbData count] ; i++) {
		if ([[[dbData objectAtIndex:i] objectForKey:@"value"] intValue]) {
			[sql appendFormat:@"%@=%@",
			 [[dbData objectAtIndex:i] objectForKey:@"key"],
			 [[dbData objectAtIndex:i] objectForKey:@"value"]];
		} else {
			[sql appendFormat:@"%@='%@'",
			 [[dbData objectAtIndex:i] objectForKey:@"key"],
			 [[dbData objectAtIndex:i] objectForKey:@"value"]];
		}		
		if (i + 1 < [dbData count]) {
			[sql appendFormat:@", "];
		}
	}
	if (where != NULL) {
		[sql appendFormat:@" WHERE %@",where];
	}		
	[self runDynamicSQL:sql forTable:table];
}
//================================================================================================================================================================================================
- (void)updateDictionary:(NSDictionary *)dbData forTable:(NSString *)table
{
	[self updateDictionary:dbData forTable:table where:NULL];
}

//================================================================================================================================================================================================
- (void)updateDictionary:(NSDictionary *)dbData forTable:(NSString *)table where:(NSString *)where
{
	
	NSMutableString *sql = [NSMutableString stringWithCapacity:16];
	[sql appendFormat:@"UPDATE %@ SET ",table];

	NSArray *dataKeys = [dbData allKeys];
	for (UInt32 i = 0 ; i < [dataKeys count] ; i++) {
		if ([[dbData objectForKey:[dataKeys objectAtIndex:i]] intValue]) {
			[sql appendFormat:@"%@='%@'",
			 [dataKeys objectAtIndex:i],
			 [dbData objectForKey:[dataKeys objectAtIndex:i]]];
		} else {
			[sql appendFormat:@"%@='%@'",
			 [dataKeys objectAtIndex:i],
			 [dbData objectForKey:[dataKeys objectAtIndex:i]]];
		}		
		if (i + 1 < [dbData count]) {
			[sql appendFormat:@", "];
		}
	}
	if (where != NULL) {
		[sql appendFormat:@" WHERE %@",where];
	}
	[self runDynamicSQL:sql forTable:table];
	
	NSLog(@"%@",sql);
}
//================================================================================================================================================================================================
- (void)updateSQL:(NSString *)sql forTable:(NSString *)table
{
	[self runDynamicSQL:sql forTable:table];
}
//================================================================================================================================================================================================
- (void)deleteWhere:(NSString *)where forTable:(NSString *)table
{

	NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@",
					 table,where];
	[self runDynamicSQL:sql forTable:table];
}

// INSERT/UPDATE/DELETE Subroutines
//================================================================================================================================================================================================
- (BOOL)runDynamicSQL:(NSString *)sql forTable:(NSString *)table {

	int result;
	NSAssert1(self.dynamic == 1, @"Tried to use a dynamic function on a static database",NULL);
	sqlite3_stmt *statement;
	if( (statement = [self prepare:sql]) ) {
		result = sqlite3_step(statement);
    }		
	sqlite3_finalize(statement);
	if (result) {
		if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(databaseTableWasUpdated:)]) {
			[delegate databaseTableWasUpdated:table];
		}	
		return YES;
	} else {
		return NO;
	}
	
}

// requirements for closing things down
//================================================================================================================================================================================================
- (void)dealloc
{
	if (dbh) {
		sqlite3_close(dbh);
	}
	[delegate release];
	[super dealloc];
}
//================================================================================================================================================================================================


#if 0

//======================================================================================================================================
- (void) initMashup {
    
    NSArray *_aryMashupsNonPassed = [[DBManager sharedDBManager] getMashupsNotBelongIntoMashupsWithPack:m_packID andAlbum:m_albumID andMashups:m_aryPassedMashupIDs];
    
    if ([_aryMashupsNonPassed count] == 0) {
        [self onTheEnd];
        return;
    }
    
    if ([_aryMashupsNonPassed count] == 1) {
        [m_lblMashupNumber setTextColor:[UIColor redColor]];
    }
    else {
        [m_lblMashupNumber setTextColor:[UIColor whiteColor]];
    }
    
    int random = rand() % [_aryMashupsNonPassed count];
    NSDictionary *_cell = [_aryMashupsNonPassed objectAtIndex:random];
    [m_aryPassedMashupIDs addObject:[_cell objectForKey:@"id"]];
    
    // Mashup Questions
    [m_lblMashupNumber setText:[NSString stringWithFormat:@"MASHUP QUESTION %d", [m_aryPassedMashupIDs count]]];
    
    // option 1
    int _option1[3];
    
    {
        int     _die[3] = {1, 2, 3};
        BOOL    _isChoosed[3] = {NO, NO, NO};
        
        for (int i = 0; i < sizeof(_die)/sizeof(_die[0]);) {
            int random = rand() % (sizeof(_die)/sizeof(_die[0]));
            
            if ( _isChoosed[random] == NO) {
                _option1[i] = _die[random];
                
                _isChoosed[random] = YES;
                i++;
            }
        }
    }
    
    [m_img1 setImage:[UIImage imageNamed:[_cell objectForKey:[NSString stringWithFormat:@"mashup%d", _option1[0]]]]];
    [m_lblTitle1 setText:[_cell objectForKey:[NSString stringWithFormat:@"mashup%dtitle", _option1[0]]]];
    
    [m_img2 setImage:[UIImage imageNamed:[_cell objectForKey:[NSString stringWithFormat:@"mashup%d", _option1[1]]]]];
    [m_lblTitle2 setText:[_cell objectForKey:[NSString stringWithFormat:@"mashup%dtitle", _option1[1]]]];
    
    [m_img3 setImage:[UIImage imageNamed:[_cell objectForKey:[NSString stringWithFormat:@"mashup%d", _option1[2]]]]];
    [m_lblTitle3 setText:[_cell objectForKey:[NSString stringWithFormat:@"mashup%dtitle", _option1[2]]]];
    
    [m_btn1 setTag:_option1[0]];
    [m_btn2 setTag:_option1[1]];
    [m_btn3 setTag:_option1[2]];
    
    [m_img1True setTag:_option1[0]];
    [m_img2True setTag:_option1[1]];
    [m_img3True setTag:_option1[2]];
    
    [m_img1False setTag:_option1[0]];
    [m_img2False setTag:_option1[1]];
    [m_img3False setTag:_option1[2]];
    
    [m_img1True setHidden:YES];
    [m_img2True setHidden:YES];
    [m_img3True setHidden:YES];
    
    [m_img1False setHidden:YES];
    [m_img2False setHidden:YES];
    [m_img3False setHidden:YES];
    
    // option 2
    int _option2[3];
    
    {
        int     _die[3] = {4, 5, 6};
        BOOL    _isChoosed[3] = {NO, NO, NO};
        
        for (int i = 0; i < sizeof(_die)/sizeof(_die[0]);) {
            int random = rand() % (sizeof(_die)/sizeof(_die[0]));
            
            if ( _isChoosed[random] == NO) {
                _option2[i] = _die[random];
                
                _isChoosed[random] = YES;
                i++;
            }
        }
    }
    
    [m_img4 setImage:[UIImage imageNamed:[_cell objectForKey:[NSString stringWithFormat:@"mashup%d", _option2[0]]]]];
    [m_lblTitle4 setText:[_cell objectForKey:[NSString stringWithFormat:@"mashup%dtitle", _option2[0]]]];
    
    [m_img5 setImage:[UIImage imageNamed:[_cell objectForKey:[NSString stringWithFormat:@"mashup%d", _option2[1]]]]];
    [m_lblTitle5 setText:[_cell objectForKey:[NSString stringWithFormat:@"mashup%dtitle", _option2[1]]]];
    
    [m_img6 setImage:[UIImage imageNamed:[_cell objectForKey:[NSString stringWithFormat:@"mashup%d", _option2[2]]]]];
    [m_lblTitle6 setText:[_cell objectForKey:[NSString stringWithFormat:@"mashup%dtitle", _option2[2]]]];
    
    [m_btn4 setTag:_option2[0]];
    [m_btn5 setTag:_option2[1]];
    [m_btn6 setTag:_option2[2]];
    
    [m_img4True setTag:_option2[0]];
    [m_img5True setTag:_option2[1]];
    [m_img6True setTag:_option2[2]];
    
    [m_img4False setTag:_option2[0]];
    [m_img5False setTag:_option2[1]];
    [m_img6False setTag:_option2[2]];
    
    [m_img4True setHidden:YES];
    [m_img5True setHidden:YES];
    [m_img6True setHidden:YES];
    
    [m_img4False setHidden:YES];
    [m_img5False setHidden:YES];
    [m_img6False setHidden:YES];
}

- (void) initAudioControl {
    [self stopSound];
    [self audioState:0]; // to play
}

- (void) initDialog {
    [self hideGreat];
    [self hideFailed];
    [self hideAgain];
}

#pragma mark
#pragma mark - Actions
//======================================================================================================================================
- (IBAction) onOption:(id)sender {
    UIButton *_button = (UIButton *)sender;
    int _imageID = [_button tag];
    
    if ( ([self isOption1:_imageID] && ![self isChoicedOption1])) {
        if ([self isTrue:_imageID]) {
            UIImageView *_imgTrue = [self trueImageMatched:_imageID];
            [_imgTrue setHidden:NO];
        }
        else {
            UIImageView *_imgFalse = [self falseImageMatched:_imageID];
            [_imgFalse setHidden:NO];
        }
        
        m_option1 = _imageID;
    }
    else if ([self isOption2:_imageID] && ![self isChoicedOption2]) {
        if ([self isTrue:_imageID]) {
            UIImageView *_imgTrue = [self trueImageMatched:_imageID];
            [_imgTrue setHidden:NO];
        }
        else {
            UIImageView *_imgFalse = [self falseImageMatched:_imageID];
            [_imgFalse setHidden:NO];
        }
        
        m_option2 = _imageID;
    }
    
    if (m_option1 != 0 && m_option2 != 0) {
        if ([self isTrue:m_option1] && [self isTrue:m_option2]) {
            [self viewGreat];
        }
        else if ([self isTrue:m_option1] && ![self isTrue:m_option2]) {
            if (m_again == 0) {
                [self viewAgain];
            }
            else if (m_again == 1) {
                [self viewFailed];
            }
        }
        else if (![self isTrue:m_option1] && [self isTrue:m_option2]) {
            if (m_again == 0) {
                [self viewAgain];
            }
            else if (m_again == 1) {
                [self viewFailed];
            }
        }
        else if (![self isTrue:m_option1] && ![self isTrue:m_option2]) {
            [self viewFailed];
        }
    }
}

//======================================================================================================================================
- (IBAction) onVolume:(id)sender {
    
    if (m_audioPlayer != nil && [m_audioPlayer isPlaying] == YES)
        [m_audioPlayer setVolume:[m_sldVolume value]];
}

//======================================================================================================================================
- (IBAction) onAudioPlay:(id)sender {
    
    if (m_musicloop < 2) {
        
        [self playSound];
        
        [self audioState:1]; // to pause
        
        m_musicloop++;
    }
}

//======================================================================================================================================
- (IBAction) onAudioStop:(id)sender {
    [self stopSound];
    
    [self audioState:0]; // to play
}

//======================================================================================================================================
- (void) playSound {
    
    [self stopSound];
    
    int mashupID = [[m_aryPassedMashupIDs lastObject] intValue];
    NSArray *_aryMashups = [[DBManager sharedDBManager] getMashupWithPack:m_packID andAlbum:m_albumID andMashup:mashupID];
    NSDictionary *_cell = [_aryMashups objectAtIndex:0];
    
    NSError *error;
    NSString *_strSound = [_cell objectForKey:@"music"];
    
    NSString *_strPath =  [[ NSBundle mainBundle] pathForResource:_strSound ofType:@"mp3"];
    
    NSURL *url = [[NSURL alloc] initFileURLWithPath:_strPath];
    
    m_audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    m_audioPlayer.delegate = self;
    
    [m_audioPlayer setVolume:[m_sldVolume value]];
    
    if (m_audioPlayer == nil) {
        NSLog(@"%@", [error description]);
    }
    else {
        [m_audioPlayer play];
    }
}

//======================================================================================================================================
- (void) stopSound {
    if (m_audioPlayer != nil) {
        [m_audioPlayer stop];
        m_audioPlayer = nil;
    }
}

//======================================================================================================================================
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self audioState:0]; // to play
}

//======================================================================================================================================
- (void) audioState:(int)_state {
    switch (_state) {
        case 0:
            // to play
            [m_btnPlay setHidden:NO];
            [m_btnPause setHidden:YES];
            break;
            
        case 1:
            // to pause
            [m_btnPlay setHidden:YES];
            [m_btnPause setHidden:NO];
        default:
            break;
    }
}

//======================================================================================================================================
- (IBAction) onHome:(id)sender {
    MUHomeViewController* _controller = [[MUHomeViewController alloc] initWithNibName:@"MUHomeViewController" bundle:nil];
    
    [[self navigationController] pushViewController:_controller animated:NO];
}

//======================================================================================================================================
- (IBAction) onNext:(id)sender {
    
    [self initQuiz];
}

//======================================================================================================================================
- (IBAction) onAgain:(id)sender {
    [self hideAgain];
    
    m_again++;
    
    if ([self isChoicedOption1] && ![self isTrue:m_option1]) {
        m_option1 = 0;
        
        [m_img1True setHidden:YES];
        [m_img2True setHidden:YES];
        [m_img3True setHidden:YES];
        
        [m_img1False setHidden:YES];
        [m_img2False setHidden:YES];
        [m_img3False setHidden:YES];
    }
    else if ([self isChoicedOption2] && ![self isTrue:m_option2]) {
        m_option2 = 0;
        
        [m_img4True setHidden:YES];
        [m_img5True setHidden:YES];
        [m_img6True setHidden:YES];
        
        [m_img4False setHidden:YES];
        [m_img5False setHidden:YES];
        [m_img6False setHidden:YES];
    }
}

#pragma mark
#pragma mark -
//======================================================================================================================================
- (BOOL) isOption1:(int)_imageID {
    return (_imageID == 1 || _imageID == 2 || _imageID == 3);
}

//======================================================================================================================================
- (BOOL) isOption2:(int)_imageID {
    return (_imageID == 4 || _imageID == 5 || _imageID == 6);
}

//======================================================================================================================================
- (BOOL) isChoicedOption1 {
    return (m_option1 != 0);
}

//======================================================================================================================================
- (BOOL) isChoicedOption2 {
    return (m_option2 != 0);
}

//======================================================================================================================================
- (BOOL) isTrue: (int)_option {
    return (_option == 1 || _option == 4);
}

//======================================================================================================================================
- (UIImageView *) trueImageMatched:(int)_imageID {
    UIImageView *_imgTrue;
    if ([m_img1True tag] == _imageID) {
        _imgTrue = m_img1True;
    }
    else if ([m_img2True tag] == _imageID) {
        _imgTrue = m_img2True;
    }
    else if ([m_img3True tag] == _imageID) {
        _imgTrue = m_img3True;
    }
    else if ([m_img4True tag] == _imageID) {
        _imgTrue = m_img4True;
    }
    else if ([m_img5True tag] == _imageID) {
        _imgTrue = m_img5True;
    }
    else if ([m_img6True tag] == _imageID) {
        _imgTrue = m_img6True;
    }
    
    return _imgTrue;
}

//======================================================================================================================================
- (UIImageView *) falseImageMatched:(int)_imageID {
    UIImageView *_imgFalse;
    if ([m_img1False tag] == _imageID) {
        _imgFalse = m_img1False;
    }
    else if ([m_img2False tag] == _imageID) {
        _imgFalse = m_img2False;
    }
    else if ([m_img3False tag] == _imageID) {
        _imgFalse = m_img3False;
    }
    else if ([m_img4False tag] == _imageID) {
        _imgFalse = m_img4False;
    }
    else if ([m_img5False tag] == _imageID) {
        _imgFalse = m_img5False;
    }
    else if ([m_img6False tag] == _imageID) {
        _imgFalse = m_img6False;
    }
    
    return _imgFalse;
}

//======================================================================================================================================
- (void) setUpView {
    [self setUpTopBar];
    [self setUpAlbum];
    [self setUpMashup];
    [self setUpAudioControl];
}

//======================================================================================================================================
- (void) setUpTopBar {
    
}

//======================================================================================================================================
- (void) setUpAlbum {
    
}

//======================================================================================================================================
- (void) setUpMashup {
    m_aryPassedMashupIDs = [[NSMutableArray alloc] initWithCapacity:0];
}

//======================================================================================================================================
- (void) setUpAudioControl {
    [m_sldVolume setThumbImage:[UIImage imageNamed:@"icon_volume_button.png"] forState:UIControlStateNormal];
    UIImage *sliderLeftTrackImage = [[UIImage imageNamed: @"icon_volume_bar.png"] stretchableImageWithLeftCapWidth: 9 topCapHeight: 0];
    UIImage *sliderRightTrackImage = [[UIImage imageNamed: @"icon_volume_bar.png"] stretchableImageWithLeftCapWidth: 9 topCapHeight: 0];
    [m_sldVolume setMinimumTrackImage: sliderLeftTrackImage forState: UIControlStateNormal];
    [m_sldVolume setMaximumTrackImage: sliderRightTrackImage forState: UIControlStateNormal];
    
    [m_sldVolume setMinimumValue:0.0f];
    [m_sldVolume setMaximumValue:1.0f];
    [m_sldVolume setValue:0.5];
}

//======================================================================================================================================
- (void) initQuiz {
    m_option1 = m_option2 = m_again = m_musicloop = 0;
    [self initAlbum];
    [self initMashup];
    [self initAudioControl];
    [self initDialog];
}

//======================================================================================================================================
- (void) initAlbum{
    [m_lblScore setText:[NSString stringWithFormat:@"%d", m_score]];
}

//======================================================================================================================================
- (void) initMashup {
    
    NSArray *_aryMashupsNonPassed = [[DBManager sharedDBManager] getMashupsNotBelongIntoMashupsWithPack:m_packID andAlbum:m_albumID andMashups:m_aryPassedMashupIDs];
    
    if ([_aryMashupsNonPassed count] == 0) {
        [self onTheEnd];
        return;
    }
    
    if ([_aryMashupsNonPassed count] == 1) {
        [m_lblMashupNumber setTextColor:[UIColor redColor]];
    }
    else {
        [m_lblMashupNumber setTextColor:[UIColor whiteColor]];
    }
    
    int random = rand() % [_aryMashupsNonPassed count];
    NSDictionary *_cell = [_aryMashupsNonPassed objectAtIndex:random];
    [m_aryPassedMashupIDs addObject:[_cell objectForKey:@"id"]];
    
    // Mashup Questions
    [m_lblMashupNumber setText:[NSString stringWithFormat:@"MASHUP QUESTION %d", [m_aryPassedMashupIDs count]]];
    
    // option 1
    int _option1[3];
    
    {
        int     _die[3] = {1, 2, 3};
        BOOL    _isChoosed[3] = {NO, NO, NO};
        
        for (int i = 0; i < sizeof(_die)/sizeof(_die[0]);) {
            int random = rand() % (sizeof(_die)/sizeof(_die[0]));
            
            if ( _isChoosed[random] == NO) {
                _option1[i] = _die[random];
                
                _isChoosed[random] = YES;
                i++;
            }
        }
    }
    
    [m_img1 setImage:[UIImage imageNamed:[_cell objectForKey:[NSString stringWithFormat:@"mashup%d", _option1[0]]]]];
    [m_lblTitle1 setText:[_cell objectForKey:[NSString stringWithFormat:@"mashup%dtitle", _option1[0]]]];
    
    [m_img2 setImage:[UIImage imageNamed:[_cell objectForKey:[NSString stringWithFormat:@"mashup%d", _option1[1]]]]];
    [m_lblTitle2 setText:[_cell objectForKey:[NSString stringWithFormat:@"mashup%dtitle", _option1[1]]]];
    
    [m_img3 setImage:[UIImage imageNamed:[_cell objectForKey:[NSString stringWithFormat:@"mashup%d", _option1[2]]]]];
    [m_lblTitle3 setText:[_cell objectForKey:[NSString stringWithFormat:@"mashup%dtitle", _option1[2]]]];
    
    [m_btn1 setTag:_option1[0]];
    [m_btn2 setTag:_option1[1]];
    [m_btn3 setTag:_option1[2]];
    
    [m_img1True setTag:_option1[0]];
    [m_img2True setTag:_option1[1]];
    [m_img3True setTag:_option1[2]];
    
    [m_img1False setTag:_option1[0]];
    [m_img2False setTag:_option1[1]];
    [m_img3False setTag:_option1[2]];
    
    [m_img1True setHidden:YES];
    [m_img2True setHidden:YES];
    [m_img3True setHidden:YES];
    
    [m_img1False setHidden:YES];
    [m_img2False setHidden:YES];
    [m_img3False setHidden:YES];
    
    // option 2
    int _option2[3];
    
    {
        int     _die[3] = {4, 5, 6};
        BOOL    _isChoosed[3] = {NO, NO, NO};
        
        for (int i = 0; i < sizeof(_die)/sizeof(_die[0]);) {
            int random = rand() % (sizeof(_die)/sizeof(_die[0]));
            
            if ( _isChoosed[random] == NO) {
                _option2[i] = _die[random];
                
                _isChoosed[random] = YES;
                i++;
            }
        }
    }
    
    [m_img4 setImage:[UIImage imageNamed:[_cell objectForKey:[NSString stringWithFormat:@"mashup%d", _option2[0]]]]];
    [m_lblTitle4 setText:[_cell objectForKey:[NSString stringWithFormat:@"mashup%dtitle", _option2[0]]]];
    
    [m_img5 setImage:[UIImage imageNamed:[_cell objectForKey:[NSString stringWithFormat:@"mashup%d", _option2[1]]]]];
    [m_lblTitle5 setText:[_cell objectForKey:[NSString stringWithFormat:@"mashup%dtitle", _option2[1]]]];
    
    [m_img6 setImage:[UIImage imageNamed:[_cell objectForKey:[NSString stringWithFormat:@"mashup%d", _option2[2]]]]];
    [m_lblTitle6 setText:[_cell objectForKey:[NSString stringWithFormat:@"mashup%dtitle", _option2[2]]]];
    
    [m_btn4 setTag:_option2[0]];
    [m_btn5 setTag:_option2[1]];
    [m_btn6 setTag:_option2[2]];
    
    [m_img4True setTag:_option2[0]];
    [m_img5True setTag:_option2[1]];
    [m_img6True setTag:_option2[2]];
    
    [m_img4False setTag:_option2[0]];
    [m_img5False setTag:_option2[1]];
    [m_img6False setTag:_option2[2]];
    
    [m_img4True setHidden:YES];
    [m_img5True setHidden:YES];
    [m_img6True setHidden:YES];
    
    [m_img4False setHidden:YES];
    [m_img5False setHidden:YES];
    [m_img6False setHidden:YES];
}

- (void) initAudioControl {
    [self stopSound];
    [self audioState:0]; // to play
}

- (void) initDialog {
    [self hideGreat];
    [self hideFailed];
    [self hideAgain];
}

#pragma mark
#pragma mark - Actions
//======================================================================================================================================
- (IBAction) onOption:(id)sender {
    UIButton *_button = (UIButton *)sender;
    int _imageID = [_button tag];
    
    if ( ([self isOption1:_imageID] && ![self isChoicedOption1])) {
        if ([self isTrue:_imageID]) {
            UIImageView *_imgTrue = [self trueImageMatched:_imageID];
            [_imgTrue setHidden:NO];
        }
        else {
            UIImageView *_imgFalse = [self falseImageMatched:_imageID];
            [_imgFalse setHidden:NO];
        }
        
        m_option1 = _imageID;
    }
    else if ([self isOption2:_imageID] && ![self isChoicedOption2]) {
        if ([self isTrue:_imageID]) {
            UIImageView *_imgTrue = [self trueImageMatched:_imageID];
            [_imgTrue setHidden:NO];
        }
        else {
            UIImageView *_imgFalse = [self falseImageMatched:_imageID];
            [_imgFalse setHidden:NO];
        }
        
        m_option2 = _imageID;
    }
    
    if (m_option1 != 0 && m_option2 != 0) {
        if ([self isTrue:m_option1] && [self isTrue:m_option2]) {
            [self viewGreat];
        }
        else if ([self isTrue:m_option1] && ![self isTrue:m_option2]) {
            if (m_again == 0) {
                [self viewAgain];
            }
            else if (m_again == 1) {
                [self viewFailed];
            }
        }
        else if (![self isTrue:m_option1] && [self isTrue:m_option2]) {
            if (m_again == 0) {
                [self viewAgain];
            }
            else if (m_again == 1) {
                [self viewFailed];
            }
        }
        else if (![self isTrue:m_option1] && ![self isTrue:m_option2]) {
            [self viewFailed];
        }
    }
}

//======================================================================================================================================
- (IBAction) onVolume:(id)sender {
    
    if (m_audioPlayer != nil && [m_audioPlayer isPlaying] == YES)
        [m_audioPlayer setVolume:[m_sldVolume value]];
}

//======================================================================================================================================
- (IBAction) onAudioPlay:(id)sender {
    
    if (m_musicloop < 2) {
        
        [self playSound];
        
        [self audioState:1]; // to pause
        
        m_musicloop++;
    }
}

//======================================================================================================================================
- (IBAction) onAudioStop:(id)sender {
    [self stopSound];
    
    [self audioState:0]; // to play
}

//======================================================================================================================================
- (void) playSound {
    
    [self stopSound];
    
    int mashupID = [[m_aryPassedMashupIDs lastObject] intValue];
    NSArray *_aryMashups = [[DBManager sharedDBManager] getMashupWithPack:m_packID andAlbum:m_albumID andMashup:mashupID];
    NSDictionary *_cell = [_aryMashups objectAtIndex:0];
    
    NSError *error;
    NSString *_strSound = [_cell objectForKey:@"music"];
    
    NSString *_strPath =  [[ NSBundle mainBundle] pathForResource:_strSound ofType:@"mp3"];
    
    NSURL *url = [[NSURL alloc] initFileURLWithPath:_strPath];
    
    m_audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    m_audioPlayer.delegate = self;
    
    [m_audioPlayer setVolume:[m_sldVolume value]];
    
    if (m_audioPlayer == nil) {
        NSLog(@"%@", [error description]);
    }
    else {
        [m_audioPlayer play];
    }
}

//======================================================================================================================================
- (void) stopSound {
    if (m_audioPlayer != nil) {
        [m_audioPlayer stop];
        m_audioPlayer = nil;
    }
}

//======================================================================================================================================
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self audioState:0]; // to play
}

//======================================================================================================================================
- (void) audioState:(int)_state {
    switch (_state) {
        case 0:
            // to play
            [m_btnPlay setHidden:NO];
            [m_btnPause setHidden:YES];
            break;
            
        case 1:
            // to pause
            [m_btnPlay setHidden:YES];
            [m_btnPause setHidden:NO];
        default:
            break;
    }
}

//======================================================================================================================================
- (IBAction) onHome:(id)sender {
    MUHomeViewController* _controller = [[MUHomeViewController alloc] initWithNibName:@"MUHomeViewController" bundle:nil];
    
    [[self navigationController] pushViewController:_controller animated:NO];
}

//======================================================================================================================================
- (IBAction) onNext:(id)sender {
    
    [self initQuiz];
}

//======================================================================================================================================
- (IBAction) onAgain:(id)sender {
    [self hideAgain];
    
    m_again++;
    
    if ([self isChoicedOption1] && ![self isTrue:m_option1]) {
        m_option1 = 0;
        
        [m_img1True setHidden:YES];
        [m_img2True setHidden:YES];
        [m_img3True setHidden:YES];
        
        [m_img1False setHidden:YES];
        [m_img2False setHidden:YES];
        [m_img3False setHidden:YES];
    }
    else if ([self isChoicedOption2] && ![self isTrue:m_option2]) {
        m_option2 = 0;
        
        [m_img4True setHidden:YES];
        [m_img5True setHidden:YES];
        [m_img6True setHidden:YES];
        
        [m_img4False setHidden:YES];
        [m_img5False setHidden:YES];
        [m_img6False setHidden:YES];
    }
}

#pragma mark
#pragma mark -
//======================================================================================================================================
- (BOOL) isOption1:(int)_imageID {
    return (_imageID == 1 || _imageID == 2 || _imageID == 3);
}

//======================================================================================================================================
- (BOOL) isOption2:(int)_imageID {
    return (_imageID == 4 || _imageID == 5 || _imageID == 6);
}

//======================================================================================================================================
- (BOOL) isChoicedOption1 {
    return (m_option1 != 0);
}

//======================================================================================================================================
- (BOOL) isChoicedOption2 {
    return (m_option2 != 0);
}

//======================================================================================================================================
- (BOOL) isTrue: (int)_option {
    return (_option == 1 || _option == 4);
}

//======================================================================================================================================
- (UIImageView *) trueImageMatched:(int)_imageID {
    UIImageView *_imgTrue;
    if ([m_img1True tag] == _imageID) {
        _imgTrue = m_img1True;
    }
    else if ([m_img2True tag] == _imageID) {
        _imgTrue = m_img2True;
    }
    else if ([m_img3True tag] == _imageID) {
        _imgTrue = m_img3True;
    }
    else if ([m_img4True tag] == _imageID) {
        _imgTrue = m_img4True;
    }
    else if ([m_img5True tag] == _imageID) {
        _imgTrue = m_img5True;
    }
    else if ([m_img6True tag] == _imageID) {
        _imgTrue = m_img6True;
    }
    
    return _imgTrue;
}

//======================================================================================================================================
- (UIImageView *) falseImageMatched:(int)_imageID {
    UIImageView *_imgFalse;
    if ([m_img1False tag] == _imageID) {
        _imgFalse = m_img1False;
    }
    else if ([m_img2False tag] == _imageID) {
        _imgFalse = m_img2False;
    }
    else if ([m_img3False tag] == _imageID) {
        _imgFalse = m_img3False;
    }
    else if ([m_img4False tag] == _imageID) {
        _imgFalse = m_img4False;
    }
    else if ([m_img5False tag] == _imageID) {
        _imgFalse = m_img5False;
    }
    else if ([m_img6False tag] == _imageID) {
        _imgFalse = m_img6False;
    }
    
    return _imgFalse;
}

#pragma mark
#pragma mark - Events
//======================================================================================================================================
- (void) onTheEnd {
    MUResultViewController * _controller = [[MUResultViewController alloc] initWithNibName:@"MUResultViewController" bundle:nil];
    [_controller setM_packID:m_packID];
    [_controller setM_albumID:m_albumID];
    [_controller setM_score:m_score];
    
    [[self navigationController] pushViewController:_controller animated:NO];
}

//======================================================================================================================================
- (void) viewGreat {
    [m_vwMask setHidden:NO];
    [m_btnNext setHidden:NO];
    [m_lblLabelGreat setHidden:NO];
    [m_lblLabelPoint setHidden:NO];
    
    int score = 20 - m_again * 5;
    m_score += score;
    
    [m_lblLabelPoint setText:[NSString stringWithFormat:@"%d points", score]];
}

- (void) viewFailed {
    [m_vwMask setHidden:NO];
    [m_btnNext setHidden:NO];
    [m_lblLabelFailed setHidden:NO];
}

//======================================================================================================================================
- (void) viewAgain {
    [m_vwMask setHidden:NO];
    [m_btnAgain setHidden:NO];
}

//======================================================================================================================================
- (void) hideGreat {
    [m_vwMask setHidden:YES];
    [m_btnNext setHidden:YES];
    [m_lblLabelGreat setHidden:YES];
    [m_lblLabelPoint setHidden:YES];
}

//======================================================================================================================================
- (void) hideAgain {
    [m_vwMask setHidden:YES];
    [m_btnAgain setHidden:YES];
}

//======================================================================================================================================
- (void) hideFailed {
    [m_vwMask setHidden:YES];
    [m_btnNext setHidden:YES];
    [m_lblLabelFailed setHidden:YES];
}

//======================================================================================================================================

- (IBAction)click_favoritesBtn:(id)sender {
    
    // Go to favorites page.
    FavoritesViewController* favoritesController;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        favoritesController = [[FavoritesViewController alloc] initWithNibName:@"FavoritesViewController" bundle:nil];
    } else {
        
        favoritesController = [[FavoritesViewController alloc] initWithNibName:@"FavoritesViewController_iPad" bundle:nil];
    }
    
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:favoritesController];
    [self presentModalViewController:navController animated:YES];
}

- (IBAction)click_homeBtn:(id)sender {
    
    [self dismissModalViewControllerAnimated:YES];
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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    NSArray* arrSC = [[DBManager sharedDBManager] getSubCategoriesName:self.mcID];
    NSDictionary *itemDic = [arrSC objectAtIndex:indexPath.row];
    NSString *strSGTitle = (NSString*)[itemDic objectForKey:@"scName"];
    cell.textLabel.text = NSLocalizedString(strSGTitle, nil);
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
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
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:emojiListController];
    [self presentModalViewController:navController animated:YES];
    
}


#endif

@end
