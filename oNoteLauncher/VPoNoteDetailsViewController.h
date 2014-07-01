//
//  VPoNoteDetailsViewController.h
//  oNoteLauncher
//
//  Created by Joel Sooriah on 02/06/2014.
//  Copyright (c) 2014 Vapor Communications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ScentsCompilationView.h"
#import "PunchScrollView.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface VPoNoteDetailsViewController : UIViewController <PunchScrollViewDataSource, PunchScrollViewDelegate, CBPeripheralDelegate> {
	;
}

@property (nonatomic, strong) PFObject *oSnap;
@property (nonatomic, strong) UIImageView *taggedPhotoImageView;
@property (nonatomic, strong) NSArray *scentsList;
@property (nonatomic, strong) NSMutableArray *tags;
@property (nonatomic, strong) UIView *sliderBox;
@property (nonatomic, strong) UISlider * customSlider;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) ScentTagView *currentlyPlayingTag;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, assign) int time;
@property (nonatomic, strong) UIButton *pauseBtn;
@property (nonatomic, strong) UIButton *resumeBtn;
@property (nonatomic, strong) UIButton *nextPageButton;
@property (nonatomic, assign) int duration;
@property (nonatomic, strong) UIView *foodieAContainerView;
@property (nonatomic, strong) UIView *foodieBContainerView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) PunchScrollView *scentsInformationView;
@property (nonatomic, strong) UIButton *replayButton;


- (id)initWithoSnap:(PFObject *)oSnap_;

@end

