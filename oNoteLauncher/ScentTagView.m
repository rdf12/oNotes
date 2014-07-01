//
//  ScentTagView.m
//  ParseStarterProject
//
//  Created by Joel Sooriah on 14/05/2014.
//
//

#import "ScentTagView.h"

@implementation ScentTagView

@synthesize scentObject;
@synthesize outerRing;
@synthesize innerRing;
@synthesize taggedScents;

- (id)initWithFrame:(CGRect)frame andScent:(PFObject *)scentObject_
{
	self = [super initWithFrame:frame];
	if (self) {
		// Initialization code
		self.scentObject = scentObject_;
		self.taggedScents = [NSMutableArray array];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		// Initialization code
		self.taggedScents = [NSMutableArray array];
	}
	return self;
}

- (void)layoutSubviews {
	
	self.backgroundColor = [UIColor clearColor];
    
    //[self paint];
    
    PFObject *lastTag = [self.taggedScents lastObject];
    UIColor *lastTagColor = [self colorFromHexString:[NSString stringWithFormat:@"#%@", [lastTag objectForKey:@"colorCode"]]];
    
	self.outerRing = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
	self.outerRing.layer.cornerRadius = (self.outerRing.frame.size.width/2);
	self.innerRing = [[UIView alloc] initWithFrame:CGRectMake(self.outerRing.frame.origin.x+5, self.outerRing.frame.origin.y+5, self.frame.size.width-10, self.frame.size.height-10)];
	self.innerRing.layer.cornerRadius = (self.innerRing.frame.size.width/2);
    
	self.outerRing.backgroundColor = [UIColor clearColor];
	self.innerRing.backgroundColor = lastTagColor;
	self.outerRing.layer.borderColor = lastTagColor.CGColor;
	self.outerRing.layer.borderWidth = 2.0;
	self.innerRing.layer.borderColor = lastTagColor.CGColor;
    
	self.innerRing.layer.borderWidth = 1.0;
	self.innerRing.alpha = 0.7;
    
	[self addSubview:self.outerRing];
	[self addSubview:self.innerRing];
}

- (void)resetColors {
	
	self.backgroundColor = [UIColor clearColor];
	self.outerRing.backgroundColor = [UIColor clearColor];
	self.innerRing.backgroundColor = [UIColor whiteColor];
	self.outerRing.layer.borderColor = [UIColor whiteColor].CGColor;
	self.innerRing.layer.borderColor = [UIColor whiteColor].CGColor;
}

- (void)paint {
    
    PFObject *lastTag = [self.taggedScents lastObject];
    UIColor *lastTagColor = [self colorFromHexString:[NSString stringWithFormat:@"#%@", [lastTag objectForKey:@"colorCode"]]];
    self.backgroundColor = lastTagColor;
	self.outerRing.backgroundColor = lastTagColor;
	self.innerRing.backgroundColor = lastTagColor;
	self.outerRing.layer.borderColor = lastTagColor.CGColor;
	self.innerRing.layer.borderColor = lastTagColor.CGColor;
}


- (UIColor *)colorFromHexString:(NSString *)hexString {
	unsigned rgbValue = 0;
	NSScanner *scanner = [NSScanner scannerWithString:hexString];
	[scanner setScanLocation:1]; // bypass '#' character
	[scanner scanHexInt:&rgbValue];
	return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}





@end









