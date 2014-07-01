//
//  BlocksViewController.m
//  BOMTalk
//
//	simplified pasteboard for text and images
//	sends the current data to a selected device and assigns it to its pasteboard
//	reloads every time you activate the APP
//
//  Created by Oliver Michalak on 24.04.13.
//  Copyright (c) 2013 Oliver Michalak. All rights reserved.
//

#import "PasteboardViewController.h"
#import "BOMTalk.h"

#define kSendText (101)
#define kSendImage (102)

@interface PasteboardViewController ()
@property (strong, nonatomic) UIProgressView *progressView;
@end

@implementation PasteboardViewController

#pragma mark view callbacks

- (void) viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.titleView = self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
	self.progressView.hidden = YES;
	self.progressView.progress = 0.5;
#ifdef BOMTalkDebug
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(debuggerShow)];
#endif
	// in order to update the pasteboard regularly
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startView:) name:UIApplicationWillEnterForegroundNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopView:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self startView:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self stopView:nil];
#ifdef BOMTalkDebug
	[[BOMTalk sharedTalk] hideDebugger];
#endif
}

- (void) viewDidUnload {
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	self.textView = nil;
	self.imageView = nil;
	self.progressView = nil;
	[super viewDidUnload];
}

- (void) startView: (NSNotification*) notification {
	BOMTalk *talker = [BOMTalk sharedTalk];
	[talker answerToUpdate:^(BOMTalkPeer *sender) {
		[self.listView reloadData];
	}];
	[talker answerToMessage:kSendText block:^(BOMTalkPeer *peer, id data) {
		UIAlertView *anAlertView = [[UIAlertView alloc] initWithTitle:@"qfdfs" message:(NSString*) data delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
		[anAlertView show];
		[self showText: (NSString*) data];
		[[UIPasteboard generalPasteboard] setData: [(NSString*)data dataUsingEncoding:NSUTF8StringEncoding] forPasteboardType:@"public.text"];
	}];
	[talker answerToMessage:kSendImage block:^(BOMTalkPeer *peer, id data) {
		[self showImage: [UIImage imageWithData: data]];
		[[UIPasteboard generalPasteboard] setData: data forPasteboardType:@"public.jpeg"];
	}];
	[talker progressForReceiving:^(float progress) {
		self.progressView.hidden = (progress == 1.0);
		self.progressView.progress = 1 - progress;
	}];
	[talker progressForSending:^(float progress) {
		self.progressView.hidden = (progress == 1.0);
		self.progressView.progress = progress;
	}];
	[[BOMTalk sharedTalk] start];
	
	UIPasteboard *pboard = [UIPasteboard generalPasteboard];
	NSData *data = [pboard dataForPasteboardType:@"public.jpeg"];
	if (data)
		[self showImage: [UIImage imageWithData: data]];
	else {
		data = [pboard dataForPasteboardType:@"public.text"];
		if (data)
			[self showText: [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
	}
}

- (void) stopView: (NSNotification*) notification {
	[[BOMTalk sharedTalk] stop];
}

#ifdef BOMTalkDebug
- (void) debuggerShow {
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(debuggerHide)];
	[[BOMTalk sharedTalk] showDebuggerFromViewController: self];
}

- (void) debuggerHide {
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(debuggerShow)];
	[[BOMTalk sharedTalk] hideDebugger];
}
#endif

#pragma mark helper methods

- (void) showImage:(UIImage*) image {
	[self.textView endEditing:YES];
	self.imageView.hidden = NO;
	self.imageView.image =  image;
	self.textView.hidden = YES;
}

- (void) showText:(NSString*) text {
	[self.textView endEditing:YES];
	self.textView.hidden = NO;
	self.textView.text = text;
	self.imageView.hidden = YES;
}

#pragma mark delegate callbacks

- (BOOL) textView:(UITextView*) textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*) text {
	if ([text isEqual:@"\n"]) {
		[self.textView endEditing:YES];
		return NO;
	}
	return YES;
}

- (NSInteger) tableView:(UITableView*) tableView numberOfRowsInSection:(NSInteger) section {
	return [BOMTalk sharedTalk].peerList.count;
}

- (UITableViewCell*) tableView:(UITableView*) tableView cellForRowAtIndexPath:(NSIndexPath*) indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PeerCell"];
	if (!cell)
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PeerCell"];
	BOMTalkPeer *peer = [BOMTalk sharedTalk].peerList[indexPath.row];
	cell.textLabel.text = peer.name;
	return cell;
}

- (void) tableView:(UITableView*) tableView didSelectRowAtIndexPath:(NSIndexPath*) indexPath {
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	[self.textView endEditing:YES];
	BOMTalk *talker = [BOMTalk sharedTalk];
	BOMTalkPeer *peer = talker.peerList[indexPath.row];
	if (self.imageView.hidden)
		//[talker sendMessage:kSendText toPeer:peer withData: self.textView.text];
		[talker sendMessage:kSendText toPeer:peer withData: @"this is the iPad !"];
	else
		[talker sendMessage:kSendImage toPeer:peer withData: UIImageJPEGRepresentation(self.imageView.image, 0.9)];
}



@end









