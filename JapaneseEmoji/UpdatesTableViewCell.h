//
//  UpdatesTableViewCell.h
//  UpdatesListView
//
//  Created by Tope on 10/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define LABEL_CATEGORYTITLE_POS_X   94
#define LABEL_CATEGORYTITLE_POS_Y   20
#define LABEL_CATEGORYTITLE_SIZE_WIDTH  175
#define LABEL_CATEGORYTITLE_SIZE_HEIGHT 45

@interface UpdatesTableViewCell : UITableViewCell
{
    
}

@property (retain, nonatomic) IBOutlet UIImageView  *iv_item_bg;
@property (retain, nonatomic) IBOutlet UILabel      *label_categoryName;


@end
