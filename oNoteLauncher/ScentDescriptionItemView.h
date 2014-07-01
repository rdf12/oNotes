//
//  ScentDescriptionItemView.h
//  oNoteLauncher
//
//  Created by Rachel Diane  on 6/7/14.
//  Copyright (c) 2014 Vapor Communications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ScentDescriptionItemView : UIView {
    
}

@property (nonatomic, strong) PFObject *scentObject;

- (id)initWithFrame:(CGRect)frame andScents:(PFObject *)scentObject;

@end
