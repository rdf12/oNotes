//
//  ScentsCompilationView.h
//  oNoteLauncher
//
//  Created by Joel Sooriah on 04/06/2014.
//  Copyright (c) 2014 Vapor Communications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScentTagView.h"

@interface ScentsCompilationView : UIView {
	;
}

@property (nonatomic, strong) ScentTagView *scentTagView;
@property (nonatomic, strong) NSArray *scentsArray;
@property (nonatomic, strong) NSString *family;

- (id)initWithScentTagView:(ScentTagView *)scentTagView forFamily:(NSString *)family_;

@end
