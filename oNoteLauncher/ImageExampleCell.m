//
//  ImageExampleCell.m
//  ParseExample
//
//  Created by Nick Barrowclough on 7/25/13.
//  Copyright (c) 2013 Nicholas Barrowclough. All rights reserved.
//

#import "ImageExampleCell.h"
#import "NSDate+TimeAgo.h"

@implementation ImageExampleCell

@synthesize parseImage, loadingSpinner;

@synthesize nameLabel;
@synthesize timeAgoLabel;
@synthesize titleLocationLabel;
@synthesize avatarImageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
	
    if (self) {
		
        // Initialization code
		
		self.backgroundColor = [UIColor whiteColor];

    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
