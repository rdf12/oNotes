//
//  ScentDescriptionItemView.m
//  oNoteLauncher
//
//  Created by Rachel Diane  on 6/7/14.
//  Copyright (c) 2014 Vapor Communications. All rights reserved.
//

#import "ScentDescriptionItemView.h"

@implementation ScentDescriptionItemView

@synthesize scentObject;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame andScents:(PFObject *)scentObject_ {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.scentObject = scentObject_;
    }
    return self;
}

- (void)layoutSubviews  {
    
    UIColor *scentColor = [self colorFromHexString:[NSString stringWithFormat:@"#%@", [self.scentObject objectForKey:@"colorCode"]]];
    
    UIView *scentView = [[UIView alloc] initWithFrame:CGRectMake(95, 10, 35, 35)];
    scentView.layer.borderColor = scentColor.CGColor;
    scentView.layer.borderWidth = 1.0;
    scentView.layer.cornerRadius = 17.5;
    scentView.backgroundColor = scentColor;
    
    UILabel *scentNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, 230, 25)];
    scentNameLabel.font = [UIFont fontWithName:@"FuturaLT-Oblique" size:22.0];
    scentNameLabel.textColor = [UIColor blackColor];
    scentNameLabel.numberOfLines = 0;
    scentNameLabel.textAlignment = NSTextAlignmentCenter;
    scentNameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    scentNameLabel.text = [self.scentObject objectForKey:@"name"];
    [self addSubview:scentNameLabel];
    
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 95, 230, 150)];
    descriptionLabel.font = [UIFont fontWithName:@"FuturaLT-Oblique" size:14.0];
    descriptionLabel.textColor = [UIColor blackColor];
    descriptionLabel.numberOfLines = 0;
    descriptionLabel.textAlignment = NSTextAlignmentCenter;
    descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    descriptionLabel.text = [self.scentObject objectForKey:@"description_en"];
    [descriptionLabel sizeToFit];
    
    [self addSubview:descriptionLabel];
    [self addSubview:scentView];
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



