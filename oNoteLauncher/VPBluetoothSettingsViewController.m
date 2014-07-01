//
//  VPBluetoothSettingsViewController.m
//  oNoteLauncher
//
//  Created by Matt Bridges on 6/26/14.
//  Copyright (c) 2014 Vapor Communications. All rights reserved.
//

#import "VPBluetoothSettingsViewController.h"
#import "VPCoreBluetoothManager.h"

@interface VPBluetoothSettingsViewController () <UITableViewDataSource, UITableViewDelegate, VPCoreBluetoothManagerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation VPBluetoothSettingsViewController

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
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(restartScan)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    self.preferredContentSize = CGSizeMake(300, 400);
    self.tableView.tintColor = [UIColor blackColor];
    self.navigationItem.title = @"Tap a Device To Connect";
}

- (void) autoConnectBluetooth {
    [VPCoreBluetoothManager sharedManager].delegate = self;
    [[VPCoreBluetoothManager sharedManager] startScanningForPeripherals];
}

- (void)viewWillAppear:(BOOL)animated {
    [[VPCoreBluetoothManager sharedManager] startScanningForPeripherals];
}

- (void)viewDidDisappear:(BOOL)animated {
    [[VPCoreBluetoothManager sharedManager] stopScanningForPeripherals];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)restartScan {
    [[VPCoreBluetoothManager sharedManager] startScanningForPeripherals];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [VPCoreBluetoothManager sharedManager].discoveredPeripherals.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    
    NSArray *discoveredPeripherals = [VPCoreBluetoothManager sharedManager].discoveredPeripherals;
    CBPeripheral *connectedPeripheral = [VPCoreBluetoothManager sharedManager].currentPeripheral;
    if (discoveredPeripherals.count > indexPath.row) {
        CBPeripheral *peripheral = discoveredPeripherals[indexPath.row];
        if (peripheral.name) {
            cell.textLabel.text = peripheral.name;
        } else {
            cell.textLabel.text = peripheral.identifier.UUIDString;
        }
        if (peripheral == connectedPeripheral) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *discoveredPeripherals = [VPCoreBluetoothManager sharedManager].discoveredPeripherals;
    if (discoveredPeripherals.count > indexPath.row) {
        [[VPCoreBluetoothManager sharedManager] connectPeripheral:discoveredPeripherals[indexPath.row]];
    }
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.frame = CGRectMake(0, 0, 24, 24);
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryView = spinner;
    [spinner startAnimating];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)oNotePeripheralDidConnect:(CBPeripheral *)peripheral {
    [self.tableView reloadData];
}

- (void)oNotePeripheralDidDisconnect:(CBPeripheral *)peripheral error:(NSError *)error {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:[NSString stringWithFormat:@"Peripheral connect failed: %@", error.description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
    [self.tableView reloadData];
}

- (void)oNotePeripheralDidFailToConnect:(CBPeripheral *)peripheral error:(NSError *)error {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:[NSString stringWithFormat:@"Peripheral connect failed: %@", error.description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
    [self.tableView reloadData];
}

- (void)oNotePeripheralWasDiscovered:(CBPeripheral *)peripheral {
    if (![VPCoreBluetoothManager sharedManager].currentPeripheral) {
        [[VPCoreBluetoothManager sharedManager] connectPeripheral:peripheral];
    }
    [self.tableView reloadData];
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
