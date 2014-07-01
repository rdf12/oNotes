//
//  ScentsCompilationView.m
//  oNoteLauncher
//
//  Created by Joel Sooriah on 04/06/2014.
//  Copyright (c) 2014 Vapor Communications. All rights reserved.
//

#import "ScentsCompilationView.h"
#import <Parse/Parse.h>

@implementation ScentsCompilationView

@synthesize scentTagView;
@synthesize scentsArray;
@synthesize family;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithScentTagView:(ScentTagView *)scentTagView_ forFamily:(NSString *)family_
{
	self = [super init];
	if (self) {
		// Initialization code
		self.scentTagView = scentTagView_;
        self.family = family_;
		//int numberOfScents = scentTagView.taggedScents.count;
	}
	return self;
}

- (id)initWithScentsArray:(NSArray *)scentsArray_
{
	self = [super init];
	if (self) {
		self.scentsArray = scentsArray_;
	}
	return self;
}

- (void)layoutSubviews  {
    
	NSArray *scents = self.scentTagView.taggedScents;
    
    NSMutableArray *scentsForThisFamily = [NSMutableArray array];
    
    for (int i = 0; i < scents.count; i++) {
		PFObject *scentObject = [scents objectAtIndex:i];
        if ([[scentObject objectForKey:@"Family"] isEqualToString:family]) {
            [scentsForThisFamily addObject:scentObject];
        }
	}
    
    for (int i = 0; i < scentsForThisFamily.count; i++) {
		UIView *scentView = [[UIView alloc] initWithFrame:CGRectMake(0, i*15, 15, 15)];
		scentView.layer.cornerRadius = 7.5;
		PFObject *scentObject = [scentsForThisFamily objectAtIndex:i];
		scentView.backgroundColor = [self colorFromHexString:[NSString stringWithFormat:@"#%@", [scentObject objectForKey:@"colorCode"]]];
		[self addSubview:scentView];
	}
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
	unsigned rgbValue = 0;
	NSScanner *scanner = [NSScanner scannerWithString:hexString];
	[scanner setScanLocation:1]; // bypass '#' character
	[scanner scanHexInt:&rgbValue];
	return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
