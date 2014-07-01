//
//  ScentTagView.h
//  ParseStarterProject
//
//  Created by Joel Sooriah on 14/05/2014.
//
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ScentTagView : UIView {
	;
}

@property (nonatomic, strong) PFObject *scentObject;
@property (nonatomic, strong) UIView *outerRing;
@property (nonatomic, strong) UIView *innerRing;
@property (nonatomic, strong) NSMutableArray *taggedScents;

- (id)initWithFrame:(CGRect)frame andScent:(PFObject *)scentObject_;
- (void)resetColors;
- (void)paint;

@end

