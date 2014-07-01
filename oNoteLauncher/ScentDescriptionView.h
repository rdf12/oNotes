//
//  ScentDescriptionView.h
//  oNoteLauncher
//
//  Created by Rachel Diane  on 6/7/14.
//  Copyright (c) 2014 Vapor Communications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScentTagView.h"

@interface ScentDescriptionView : UIView {
    
}

@property (nonatomic, strong) ScentTagView *scentTagView;
@property (nonatomic, strong) NSArray *scentsArray;

- (id)initWithFrame:(CGRect)frame andScents:(NSArray *)scentsArray;

@end


