//
//  VPoNoteDetailsViewController.m
//  oNoteLauncher
//
//  Created by Joel Sooriah on 02/06/2014.
//  Copyright (c) 2014 Vapor Communications. All rights reserved.
//

#import "VPoNoteDetailsViewController.h"
#import <Parse/Parse.h>
#import "ScentTagView.h"
#import "VPAppDelegate.h"
#import "NSTimer+Extras.h"
#import "ScentsCompilationView.h"
#import "VPPromotionsViewController.h"
#import "PunchScrollView.h"
#import "ScentDescriptionView.h"
#import "UIView+Toast.h"
#import "VPCoreBluetoothManager.h"

@interface VPoNoteDetailsViewController ()
@end

@implementation VPoNoteDetailsViewController

@synthesize replayButton;
@synthesize sliderBox;
@synthesize pageControl;
@synthesize scentsInformationView;
@synthesize oSnap;
@synthesize taggedPhotoImageView;
@synthesize scentsList;
@synthesize tags;
@synthesize customSlider;
@synthesize timer;
@synthesize duration;
@synthesize currentlyPlayingTag;
@synthesize foodieAContainerView;
@synthesize foodieBContainerView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
	return self;
}

- (id)initWithFrame:(CGRect)frame andONote:(PFObject *)oNote {
	self = [super init];
    if (self) {
        // Custom initialization
		
    }
	return self;
}

- (id)initWithoSnap:(PFObject *)oSnap_ {
	self = [super init];
    if (self) {
        // Custom initialization
		self.oSnap = oSnap_;
    }
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// Do any additional setup after loading the view.
	
	VPAppDelegate *d = (VPAppDelegate *)[[UIApplication sharedApplication] delegate];
	if (!d.connected_peripheral) {
		// [self.view makeToast:@"No ble device connected right now"];
	} else {
		[d.connected_peripheral setDelegate:self];
	}
	
	self.navigationItem.title = [self.oSnap objectForKey:@"title"];
	UIImage *temp = [[UIImage imageNamed:@"backButton"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
	UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithImage:temp style:UIBarButtonItemStyleBordered target:self action:@selector(pop)];
	self.navigationItem.leftBarButtonItem = barButtonItem;
	
	self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, 100, 50)];
	
	self.pauseBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.pauseBtn.tintColor = [UIColor whiteColor];
	[self.pauseBtn addTarget:self action:@selector(pause) forControlEvents:UIControlEventTouchUpInside];
	self.pauseBtn.frame = CGRectMake(380, 655, 27, 33);
	[self.pauseBtn setImage:[UIImage imageNamed:@"pauseBttnImage.png"] forState:UIControlStateNormal];
	self.resumeBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.resumeBtn.tintColor = [UIColor whiteColor];
	self.resumeBtn.hidden = YES;
	[self.resumeBtn addTarget:self action:@selector(resume) forControlEvents:UIControlEventTouchUpInside];
	self.resumeBtn.frame = CGRectMake(380, 655, 27, 33);
	[self.resumeBtn setImage:[UIImage imageNamed:@"playButtonImage.png"] forState:UIControlStateNormal];
	
	self.tags = [NSMutableArray array];
	
	VPAppDelegate *appDelegate = (VPAppDelegate *)[[UIApplication sharedApplication] delegate];
	self.scentsList = appDelegate.allScents;
	self.view.backgroundColor = [UIColor whiteColor];
	self.taggedPhotoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width-50)];
	self.taggedPhotoImageView.userInteractionEnabled = YES;
	
	PFFile *imageFile = [self.oSnap objectForKey:@"image"];
	[imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
		if (!error) {
			self.taggedPhotoImageView.image = [UIImage imageWithData:data];
		}
	}];
	
	[self.view addSubview:self.taggedPhotoImageView];
	[self buildTags];
	
	UIView *vocabsView = [[UIView alloc] initWithFrame:CGRectMake(0, self.taggedPhotoImageView.frame.size.height, self.view.frame.size.width, 200)];
	UILabel *vocabsViewHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, vocabsView.frame.size.width, 40)];
	vocabsViewHeaderLabel.textColor = [UIColor whiteColor];
	vocabsViewHeaderLabel.font = [UIFont fontWithName:@"Helvetica" size:20];
	vocabsViewHeaderLabel.backgroundColor = [UIColor darkGrayColor];
	vocabsViewHeaderLabel.text = @"Aromatic Vocabulary";
	vocabsViewHeaderLabel.textAlignment = NSTextAlignmentCenter;
	[vocabsView addSubview:vocabsViewHeaderLabel];
	
	self.foodieAContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, vocabsViewHeaderLabel.frame.size.height, self.view.frame.size.width, 100)];
	
	[vocabsView addSubview:self.foodieAContainerView];
	UIImageView *separatorView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.foodieAContainerView.frame.size.height-2, self.view.frame.size.width, 2)];
	separatorView.image = [UIImage imageNamed:@"separator"];
	[self.foodieAContainerView addSubview:separatorView];
	
	self.foodieBContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, foodieAContainerView.frame.size.height+vocabsViewHeaderLabel.frame.size.height, self.view.frame.size.width, 100)];
	[vocabsView addSubview:self.foodieBContainerView];
	
	UIImageView *labelsImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, 40, 202)];
	labelsImage.image = [UIImage imageNamed:@"labels"];
	[vocabsView addSubview:labelsImage];
	
	[self.view addSubview:vocabsView];
	
	CGRect frame = CGRectMake(40, 10, 700, 60);
	self.sliderBox = [[UIView alloc] initWithFrame:frame];
	self.sliderBox.tag = 888;
	self.sliderBox.layer.borderColor = [UIColor colorWithRed:(140/255.0) green:(136/255.0) blue:(135/255.0) alpha:1.0].CGColor;
	self.sliderBox.layer.borderWidth = 5.0;
	CGRect frame_ = CGRectMake(40, 0, 625, 60);
	self.customSlider = [[UISlider alloc] initWithFrame:frame_];
	UIImageView *sliderLeft = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"slider_right"]];
	sliderLeft.frame = CGRectMake(self.sliderBox.frame.size.width-35, 5, 25, 55);
	[self.sliderBox addSubview:sliderLeft];
	UIImageView *sliderRight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"slider_left"]];
	sliderRight.frame = CGRectMake(5, 5, 25, 55);
	[self.sliderBox addSubview:sliderRight];
	[self.customSlider setThumbImage:[UIImage imageNamed:@"uislider_cursor"] forState:UIControlStateNormal];
	self.customSlider.backgroundColor = [UIColor clearColor];
	[self.customSlider setMinimumTrackImage:[UIImage alloc] forState:UIControlStateNormal];
	[self.customSlider setMaximumTrackImage:[UIImage alloc] forState:UIControlStateNormal];
	[customSlider addTarget:self action:nil forControlEvents:UIControlEventValueChanged];
	[self configureSlider];
	[self.sliderBox addSubview:self.customSlider];
	[self.view addSubview:self.sliderBox];
	
	self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timePlus) userInfo:nil repeats:YES];
	self.time = 0;
	self.resumeBtn.hidden = YES;
	
	[self.view addSubview:self.timeLabel];
	[self.view addSubview:self.pauseBtn];
	[self.view addSubview:self.resumeBtn];
	
	UIButton *nextPageButton = [UIButton buttonWithType:UIButtonTypeCustom];
	nextPageButton.frame = CGRectMake(735, 830, 26, 44);
	[nextPageButton setImage:[UIImage imageNamed:@"right"] forState:UIControlStateNormal];
	
	[self pause];
	
	UITapGestureRecognizer *tapGesutre = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnPage:)];
    [self.taggedPhotoImageView addGestureRecognizer:tapGesutre];
}

- (void)tapOnPage:(UITapGestureRecognizer *)recognizer {
	
	CGPoint point = [recognizer locationInView:self.taggedPhotoImageView];
	if ( CGRectContainsPoint(CGRectMake(620, 25, 100, 50),point)) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.indiegogo.com/project/preview/6c6044b2"]];
	}
}

- (void)pause {
	
	self.resumeBtn.hidden = NO;
    self.pauseBtn.hidden = YES;
    
	for (CALayer* layer in [foodieAContainerView.layer sublayers]) {
		[layer removeAllAnimations];
    }
    
    [self.timer pauseTimer];
    self.scentsInformationView.hidden = NO;
}

- (void)resume {
    
    self.pauseBtn.hidden = NO;
    self.resumeBtn.hidden = YES;
	
	[self.timer resumeTimer];
	self.scentsInformationView.hidden = YES;
	[self resumeTimeLineForTag:self.currentlyPlayingTag];
}

- (void)timePlus {
	
	if (self.time == duration) {
		[self.timer invalidate];
		self.time = 0;
        self.currentlyPlayingTag = nil;
		[self showPromotionsImage];
		return;
	}
	
    self.time++;
	
	if (self.time == 1) {
		
		NSLog(@"should show scent at index : %d", 0);
		
		self.currentlyPlayingTag = [self.tags objectAtIndex:0];
		[self animateTimeLineForTag:[self.tags objectAtIndex:0]];
		[self showInformationForTagAtIndex:0];
        [self sendBytesForTagScentView:[self.tags objectAtIndex:0]];
		
	} else if (self.time%5==0) {
		
		NSLog(@"should show scent at index : %d", self.time/5);
		
		if (self.tags.count > self.time/5) {
			
            self.currentlyPlayingTag = [self.tags objectAtIndex:self.time/5];
			[self animateTimeLineForTag:[self.tags objectAtIndex:self.time/5]];
            [self showInformationForTagAtIndex:self.time/5];
            [self sendBytesForTagScentView:[self.tags objectAtIndex:self.time/5]];
		}
	}
	
    [UIView animateKeyframesWithDuration:1.0 delay:0 options:UIViewKeyframeAnimationOptionCalculationModePaced animations:^{
		[self.customSlider setValue:self.time  animated:YES];
	} completion:^(BOOL finished) {
		//[self.customSlider setValue:self.time animated:YES];
	}];
}

- (void)viewDidUnload
{
    [self setTimeLabel:nil];
    [self setPauseBtn:nil];
    [self setResumeBtn:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)buildTags {
    
	NSString *tagged_scents = [self.oSnap objectForKey:@"associated_scents"];
	NSError *e;
	NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData: [tagged_scents dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error:&e];
	
	NSArray *keys_ = [JSON allKeys];
	
    for (NSString *aKey in keys_) {
        
        NSDictionary *tagDictionary = [JSON objectForKey:aKey];
        NSArray *tagDictionaryKeys = [tagDictionary allKeys];
        ScentTagView *aScentTagView = [[ScentTagView alloc] initWithFrame:CGRectMake([[tagDictionary objectForKey:@"xPos"] floatValue]*2.4, [[tagDictionary objectForKey:@"yPos"] floatValue]*2.4, 80, 80)];
        
		for (NSString *tagDictionaryKey in tagDictionaryKeys) {
            
			if (![tagDictionaryKey isEqualToString:@"xPos"] && ![tagDictionaryKey isEqualToString:@"yPos"] && ![tagDictionaryKey isEqualToString:@"colorCode"] && ![tagDictionaryKey isEqualToString:@"name"]) {
                
				NSLog(@"tag dictionary : %@", [tagDictionary objectForKey:tagDictionaryKey]);
				NSArray *scentObjects = [self getObjectWithObjectId:[tagDictionary objectForKey:tagDictionaryKey]];
				[aScentTagView.taggedScents addObjectsFromArray:scentObjects];
			}
		}
		aScentTagView.tag = 888;
		aScentTagView.alpha = 0.7;
		[aScentTagView paint];
		[self.tags addObject:aScentTagView];
		[self.taggedPhotoImageView addSubview:aScentTagView];
	}
}

- (NSArray *)getObjectWithObjectId:(NSString *)object_id {
	NSLog(@"object_id : %@", object_id);
	NSMutableArray *objects = [NSMutableArray array];
	for (id object in scentsList) {
		NSString *ObjectId = [object valueForKeyPath:@"objectId"];
		if ([[object_id stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:ObjectId]) {
			[objects addObject:object];
		}
	}
	return [NSArray arrayWithArray:objects];
}

- (void)animateTimeLineForTag:(ScentTagView *)tag {
    
    tag.alpha = 1;
    
	NSMutableArray *foodieAScentsArray = [NSMutableArray array];
	NSMutableArray *foodieBScentsArray = [NSMutableArray array];
	
	NSArray *taggedScents = tag.taggedScents;
	
	for (PFObject *scent in taggedScents) {
		
		NSString *family = [scent objectForKey:@"Family"];
		
		if ([family isEqualToString:@"base"]) {
			
			[foodieAScentsArray addObject:scent];
			
			ScentsCompilationView *scentsCompilView = [[ScentsCompilationView alloc] initWithScentTagView:tag forFamily:family];
			[scentsCompilView layoutSubviews];
            scentsCompilView.frame = CGRectMake(384*2-20, 25, scentsCompilView.frame.size.width, scentsCompilView.frame.size.height);
            [self.foodieAContainerView addSubview:scentsCompilView];
            self.currentlyPlayingTag = tag;
			
			[UIView animateWithDuration:5 delay:0.5 options:UIViewAnimationOptionTransitionNone animations:^(void) {
				scentsCompilView.frame = CGRectMake(0, 25, scentsCompilView.frame.size.width, scentsCompilView.frame.size.height);
			} completion:^(BOOL finished) {
				[scentsCompilView removeFromSuperview];
			}];
			
		} else {
			
			[foodieBScentsArray addObject:scent];
			ScentsCompilationView *scentsCompilView = [[ScentsCompilationView alloc] initWithScentTagView:tag forFamily:family];
			[scentsCompilView layoutSubviews];
			scentsCompilView.frame = CGRectMake(384*2-20, 25, scentsCompilView.frame.size.width, scentsCompilView.frame.size.height);
			[self.foodieBContainerView addSubview:scentsCompilView];
			[UIView animateKeyframesWithDuration:5 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
				scentsCompilView.frame = CGRectMake(0, 25, scentsCompilView.frame.size.width, scentsCompilView.frame.size.height);
			} completion:^(BOOL finished) {
				[scentsCompilView removeFromSuperview];
			}];
		}
	}
}

- (void)resumeTimeLineForTag:(ScentTagView *)tag {
    
	NSMutableArray *foodieAScentsArray = [NSMutableArray array];
	NSMutableArray *foodieBScentsArray = [NSMutableArray array];
	
	NSArray *taggedScents = tag.taggedScents;
	
	for (PFObject *scent in taggedScents) {
		
		NSString *family = [scent objectForKey:@"Family"];
		
		if ([family isEqualToString:@"base"]) {
			
			[foodieAScentsArray addObject:scent];
			ScentsCompilationView *scentsCompilView = [[ScentsCompilationView alloc] initWithScentTagView:tag forFamily:family];
			[scentsCompilView layoutSubviews];
            int newTime = self.time % 5;
            scentsCompilView.frame = CGRectMake(384*2-20-(newTime*150), 25, scentsCompilView.frame.size.width, scentsCompilView.frame.size.height);
            [self.foodieAContainerView addSubview:scentsCompilView];
            self.currentlyPlayingTag = tag;
            [UIView animateWithDuration:5-newTime animations:^{
                scentsCompilView.frame = CGRectMake(0, 25, scentsCompilView.frame.size.width, scentsCompilView.frame.size.height);
            }];
			
		} else {
			
			[foodieBScentsArray addObject:scent];
			ScentsCompilationView *scentsCompilView = [[ScentsCompilationView alloc] initWithScentTagView:tag forFamily:family];
			[scentsCompilView layoutSubviews];
			scentsCompilView.frame = CGRectMake(384*2-20-(self.time*150), 25, scentsCompilView.frame.size.width, scentsCompilView.frame.size.height);
			[self.foodieBContainerView addSubview:scentsCompilView];
            self.currentlyPlayingTag = tag;
			[UIView animateKeyframesWithDuration:5 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
				scentsCompilView.frame = CGRectMake(0, 25, scentsCompilView.frame.size.width, scentsCompilView.frame.size.height);
			} completion:^(BOOL finished) {
				[scentsCompilView removeFromSuperview];
			}];
		}
	}
}


- (void)configureSlider {
	self.customSlider.minimumValue = 0.0;
	self.customSlider.maximumValue = self.tags.count * 5;
	self.duration = self.tags.count * 5;
	self.customSlider.continuous = YES;
	self.customSlider.value = 0;
}

- (void)playAnimationForScentTagView:(ScentTagView *)aScentTagView andCategory:(NSString *)scentCategory {
	
	UIView *scentTagViewColumnView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 40)];
	scentTagViewColumnView.backgroundColor = [UIColor blackColor];
}

- (void)showNotesForScentTagView {
	;
}

- (void)pop {
    for (CALayer* layer in [foodieAContainerView.layer sublayers]) {
        [layer removeAllAnimations];
    }
    for (CALayer* layer in [foodieBContainerView.layer sublayers]) {
        [layer removeAllAnimations];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showInformationForTagAtIndex:(int)index_ {
	
	if (self.scentsInformationView) {
		[self.scentsInformationView removeFromSuperview];
		self.scentsInformationView = nil;
	}
	
	self.currentlyPlayingTag = [self.tags objectAtIndex:index_];
	self.scentsInformationView = [[PunchScrollView alloc] initWithFrame:CGRectMake(40, self.taggedPhotoImageView.frame.size.height+35, self.view.frame.size.width-20, 208)];
	self.scentsInformationView.hidden = YES;
	self.scentsInformationView.backgroundColor = [UIColor whiteColor];
	self.scentsInformationView.delegate = self;
	self.scentsInformationView.dataSource = self;
	[self.scentsInformationView reloadData];
	
	[self.view addSubview:self.scentsInformationView];
}

- (void)showInformationForCurrentlyPlayingTag {
    
    if (self.scentsInformationView) {
        [self.scentsInformationView removeFromSuperview];
        self.scentsInformationView = nil;
    }
	
    self.currentlyPlayingTag = [self.tags objectAtIndex:0];
    self.scentsInformationView = [[PunchScrollView alloc] initWithFrame:CGRectMake(40, self.taggedPhotoImageView.frame.size.height+35, self.view.frame.size.width-20, 205)];
    self.scentsInformationView.delegate = self;
    self.scentsInformationView.dataSource = self;
    [self.view addSubview:self.scentsInformationView];
    [self.scentsInformationView reloadData];
}

- (NSInteger)punchscrollView:(PunchScrollView *)scrollView numberOfPagesInSection:(NSInteger)section {
    
    int taggedScentsCount = self.currentlyPlayingTag.taggedScents.count;
    if (taggedScentsCount <= 3) {
        return 1;
    } else {
        int ceiledValue = ceil(taggedScentsCount/3)+1;
        NSLog(@"%d", ceiledValue);
        return ceiledValue;
    }
}

- (NSInteger)numberOfLazyLoadingPages {
    return 1;
}

- (UIView *)punchScrollView:(PunchScrollView*)scrollView viewForPageAtIndexPath:(NSIndexPath *)indexPath {
	
	NSArray *scents = [NSArray array];
	int taggedScentsCount = self.currentlyPlayingTag.taggedScents.count;
	
	NSLog(@"tagged scents count : %d", taggedScentsCount);
	
    int lowerRange;
	
	if (taggedScentsCount < 4) {
		
		scents = self.currentlyPlayingTag.taggedScents;
		
	} else if (taggedScentsCount < 7) {
		
		if (indexPath.row == 0) {
			lowerRange = 0;
			scents = [self.currentlyPlayingTag.taggedScents subarrayWithRange:NSMakeRange(lowerRange, 3)];
		} else if (indexPath.row == 1) {
            
			lowerRange = 3;
			if (taggedScentsCount%3 == 0) {
				scents = [self.currentlyPlayingTag.taggedScents subarrayWithRange:NSMakeRange(lowerRange, taggedScentsCount/3)];
			} else {
				scents = [self.currentlyPlayingTag.taggedScents subarrayWithRange:NSMakeRange(lowerRange, taggedScentsCount-lowerRange)];
			}
		}
		
    } else if (taggedScentsCount < 9) {
		
		if (indexPath.row == 0) {
            
			lowerRange = 0;
			scents = [self.currentlyPlayingTag.taggedScents subarrayWithRange:NSMakeRange(lowerRange, 3)];
            
		} else if (indexPath.row == 1) {
            
            lowerRange = 3;
            if (taggedScentsCount%3 == 0) {
                scents = [self.currentlyPlayingTag.taggedScents subarrayWithRange:NSMakeRange(lowerRange, taggedScentsCount/3)];
            } else {
                scents = [self.currentlyPlayingTag.taggedScents subarrayWithRange:NSMakeRange(lowerRange, taggedScentsCount/3+1)];
            }
        }
    }
    
    ScentDescriptionView *aView = [[ScentDescriptionView alloc] initWithFrame:self.scentsInformationView.frame andScents:scents];
    
    return aView;
}

- (void)sendBytesForTagScentView:(ScentTagView *)aScentTagView {

    NSMutableArray *scents = [NSMutableArray array];
    for (PFObject *scent in aScentTagView.taggedScents) {
        NSString *code = [scent objectForKey:@"blecode"];
        if (code) {
            [scents addObject:[code substringFromIndex:1]]; // Strip off leading "B"
        } else {
            NSLog(@"WARNING: No blecode for scent: %@", scent);
        }
    }
    
    NSInteger payloadLength = scents.count + 1;
    if (payloadLength > 1) {
        
        char bytes[payloadLength];
        bytes[0] = scents.count;
        for (int i = 0; i < scents.count; i++) {
            char val = strtoul([scents[i] UTF8String], NULL, 2);
            bytes[i+1] = val;
        }
    
        NSData *payload = [NSData dataWithBytes:bytes length:payloadLength];
        NSLog(@"Payload: %@", payload);
        [[VPCoreBluetoothManager sharedManager] writeData:payload];
    }
}

- (void)showPromotionsImage {
	
	UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(620, 25, 100, 50)];
	[self.taggedPhotoImageView addSubview:tempView];
	self.taggedPhotoImageView.userInteractionEnabled = YES;
	
	if (self.replayButton) {
		[self.replayButton removeFromSuperview];
		self.replayButton = nil;
	}
	
	self.replayButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[self.replayButton addTarget:self action:@selector(restartPlayBack) forControlEvents:UIControlEventTouchUpInside];
	self.replayButton.frame = CGRectMake(350, 550, 62, 107);
	[self.replayButton setImage:[UIImage imageNamed:@"Replay.png"] forState:UIControlStateNormal];
	
	[self.taggedPhotoImageView addSubview:replayButton];
	[self cleanTags];
	
	self.customSlider.hidden = YES;
	self.taggedPhotoImageView.image = [UIImage imageNamed:@"indiegogo_promotion.jpg"];
}

- (void)restartPlayBack {
	
	replayButton.hidden = YES;
	
	CGRect frame = CGRectMake(40, 10, 700, 60);
	self.sliderBox = [[UIView alloc] initWithFrame:frame];
	self.sliderBox.tag = 888;
	self.sliderBox.layer.borderColor = [UIColor colorWithRed:(140/255.0) green:(136/255.0) blue:(135/255.0) alpha:1.0].CGColor;
	self.sliderBox.layer.borderWidth = 5.0;
	CGRect frame_ = CGRectMake(40, 10, 625, 60);
	self.customSlider = [[UISlider alloc] initWithFrame:frame_];
	UIImageView *sliderLeft = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"slider_right"]];
	sliderLeft.frame = CGRectMake(self.sliderBox.frame.size.width-35, 5, 25, 55);
	[self.sliderBox addSubview:sliderLeft];
	UIImageView *sliderRight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"slider_left"]];
	sliderRight.frame = CGRectMake(5, 5, 25, 55);
	[self.sliderBox addSubview:sliderRight];
	[self.customSlider setThumbImage:[UIImage imageNamed:@"uislider_cursor"] forState:UIControlStateNormal];
	self.customSlider.backgroundColor = [UIColor clearColor];
	[self.customSlider setMinimumTrackImage:[UIImage alloc] forState:UIControlStateNormal];
	[self.customSlider setMaximumTrackImage:[UIImage alloc] forState:UIControlStateNormal];
	[customSlider addTarget:self action:nil forControlEvents:UIControlEventValueChanged];
	[self configureSlider];
	[self.sliderBox addSubview:self.customSlider];
	
	[self.view addSubview:self.sliderBox];
	
	self.pauseBtn.hidden = NO;
	self.resumeBtn.hidden = NO;
	
	self.taggedPhotoImageView.userInteractionEnabled = YES;
	PFFile *imageFile = [self.oSnap objectForKey:@"image"];
	[imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
		if (!error) {
			self.taggedPhotoImageView.image = [UIImage imageWithData:data];
		}
	}];
	
	self.sliderBox.hidden = NO;
	self.customSlider.hidden = NO;
	self.time = 0;
	self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timePlus) userInfo:nil repeats:YES];
	self.resumeBtn.hidden = YES;
	
	[self buildTags];
	[self configureSlider];
	
	[self pause];
}

- (void)cleanTags {
	
	[self.tags removeAllObjects];
	[self.sliderBox removeFromSuperview];
	NSArray *subviews = self.taggedPhotoImageView.subviews;
	for (UIView *aSubview in subviews) {
		if (aSubview.tag == 888) {
			[aSubview removeFromSuperview];
		}
	}
}

#pragma mark delegate - Core Bluetooth CBPeripheral Delegate

- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral NS_AVAILABLE(NA, 6_0) {
	;
}

- (void)peripheralDidInvalidateServices:(CBPeripheral *)peripheral NS_DEPRECATED(NA, NA, 6_0, 7_0) {
	;
}


- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray *)invalidatedServices NS_AVAILABLE(NA, 7_0) {
	;
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
	;
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
	;
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error {
	;
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
	;
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
	;
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
	;
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
	;
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
	;
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
	;
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
	;
}

@end



