//
//  ScentDescriptionView.m
//  oNoteLauncher
//
//  Created by Rachel Diane  on 6/7/14.
//  Copyright (c) 2014 Vapor Communications. All rights reserved.
//

#import "ScentDescriptionView.h"
#import "ScentDescriptionItemView.h"
#import "ScentTagView.h"
#import <Parse/Parse.h>

@implementation ScentDescriptionView

@synthesize scentTagView;
@synthesize scentsArray;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame scentTag:(ScentTagView *)scentTagView_ forIndex:(int)index
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        // Initialization code
        
        
    }
	
    return self;
}


- (id)initWithFrame:(CGRect)frame andScents:(NSArray *)scentsArray_
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        // Initialization code
        self.scentsArray = scentsArray_;
    }
	
    return self;
}

- (void)layoutSubviews  {
    
    int scentsArrayCount = self.scentsArray.count;
    
    for (int i = 0; i < self.scentsArray.count; i++) {
        
        PFObject *scentObject = [self.scentsArray objectAtIndex:i];
        
        CGFloat startPos = 240;
        
        if (scentsArrayCount == 1) {
            
            startPos = 240;
            
        } else if (scentsArrayCount == 2) {
            
            startPos = 140;
            
            
        } else if (scentsArrayCount == 3) {
            
            
            startPos = 0;
        }
        
        ScentDescriptionItemView *itemView = [[ScentDescriptionItemView alloc] initWithFrame:CGRectMake(startPos+(245*i), 0, 220, 200) andScents:scentObject];
        itemView.backgroundColor = [UIColor clearColor];
        [self addSubview:itemView];
    }
    
    if (scentsArrayCount == 2) {
    
        int startPos = 140;
        int i = 1;
        UIView *separatorView0 = [[UIView alloc] initWithFrame:CGRectMake(startPos+(235*i), 35, 1, 160)];
        separatorView0.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:separatorView0];
    
    } else if (scentsArrayCount == 3) {
        
		int i = 1;
		int startPos = 140;
		
        UIView *separatorView0 = [[UIView alloc] initWithFrame:CGRectMake(240, 35, 1, 160)];
        separatorView0.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:separatorView0];
        
        UIView *separatorView1 = [[UIView alloc] initWithFrame:CGRectMake(480, 35, 1, 160)];
        separatorView1.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:separatorView1];
    }
}


#pragma mark - Color Code

- (UIColor *)colorFromHexString:(NSString *)hexString {
	
	unsigned rgbValue = 0;
	NSScanner *scanner = [NSScanner scannerWithString:hexString];
	[scanner setScanLocation:1]; // bypass '#' character
	[scanner scanHexInt:&rgbValue];
	return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}



@end



