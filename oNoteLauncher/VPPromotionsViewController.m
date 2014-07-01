//
//  VPPromotionsViewController.m
//  oNoteLauncher
//
//  Created by Joel Sooriah on 06/06/2014.
//  Copyright (c) 2014 Vapor Communications. All rights reserved.
//

#import "VPPromotionsViewController.h"

@interface VPPromotionsViewController ()

@end

@implementation VPPromotionsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImage *temp = [[UIImage imageNamed:@"backButton"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
	UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithImage:temp style:UIBarButtonItemStyleBordered target:self action:@selector(pop)];
	self.navigationItem.leftBarButtonItem = barButtonItem;
	
	UIImageView *firstImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/2)];
	firstImage.image = [UIImage imageNamed:@"image_purchase"];
	
	UIImageView *secondImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, firstImage.frame.size.height, self.view.frame.size.width, self.view.frame.size.height/2)];
	secondImage.image = [UIImage imageNamed:@"image_visit"];
	
	[self.view addSubview:firstImage];
	[self.view addSubview:secondImage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pop {
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end




