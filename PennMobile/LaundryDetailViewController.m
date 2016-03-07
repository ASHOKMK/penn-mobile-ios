//
//  LaundryDetailViewController.m
//  PennMobile
//
//  Created by Krishna Bharathala on 11/13/15.
//  Copyright © 2015 PennLabs. All rights reserved.
//

#import "LaundryDetailViewController.h"
#import "LaundryWasherDetailTableViewCell.h"
#import "LaundryDryerDetailTableViewCell.h"

@interface LaundryDetailViewController ()

@property (nonatomic, strong) UISegmentedControl *laundrySegment;
@property (nonatomic, strong) NSArray *hallLaundryList;
@property (nonatomic) BOOL hasLoaded;

@property (nonatomic, strong) NSMutableArray *washerList;
@property (nonatomic, strong) NSMutableArray *dryerList;

@end

@implementation LaundryDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.hasLoaded = NO;
    self.title = self.houseName;
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    [backButtonItem setTintColor:[UIColor redColor]];
    
    NSArray *itemArray = [NSArray arrayWithObjects: @"WASHERS", @"DRYERS", nil];
    self.laundrySegment = [[UISegmentedControl alloc] initWithItems:itemArray];
    self.laundrySegment.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
    [self.laundrySegment addTarget:self action:@selector(changed) forControlEvents: UIControlEventValueChanged];
    self.laundrySegment.selectedSegmentIndex = 0;
    self.laundrySegment.layer.borderWidth =1.5f;
    [self.view addSubview:self.laundrySegment];
    
    self.tableView.frame = CGRectMake(0, 44, self.view.frame.size.width, 0);
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.allowsSelection = NO;
    
    NSLog(@"AW = %d", self.aw);
    NSLog(@"AD = %d", self.ad);
    NSLog(@"UW = %d", self.uw);
    NSLog(@"UD = %d", self.ud);
}

-(void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.hasLoaded) {
        [self pull:self];
        self.hasLoaded = YES;
    }
}

- (void) pull:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.tableView.userInteractionEnabled = NO;
    [self performSelectorInBackground:@selector(loadFromAPI) withObject:nil];
}

-(void) loadFromAPI {
    NSString *str= [NSString stringWithFormat:@"http://api.pennlabs.org/laundry/hall/%@", self.indexNumber];
    NSURL *url =[NSURL URLWithString:str];
    
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        } else {
            NSError* error;
            NSDictionary *success = [NSJSONSerialization JSONObjectWithData:data
                                                                    options:kNilOptions
                                                                      error:&error];
            
            self.hallLaundryList = [success objectForKey:@"machines"];
                                
            self.washerList = [[NSMutableArray alloc] init];
            self.dryerList = [[NSMutableArray alloc] init];
            
            for(NSDictionary *machine in self.hallLaundryList) {
                if ([[machine objectForKey:@"machine_type"] rangeOfString:@"washer"
                                                                  options:NSCaseInsensitiveSearch].location != NSNotFound) {
                    [self.washerList addObject:machine];
                } else {
                    [self.dryerList addObject:machine];
                }
            }
        }
        
        [self performSelectorOnMainThread:@selector(hideActivity) withObject:nil waitUntilDone:NO];
        [self.tableView reloadData];
    }];
}

- (void)hideActivity {
    self.tableView.userInteractionEnabled = YES;
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

-(void) changed {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0) {
        return 44;
    }if(indexPath.row == 1) {
        return 50*3;
    } else {
        return 50;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.laundrySegment.selectedSegmentIndex == 0) {
        return [self.washerList count]+2;
    } else {
        return [self.dryerList count]+2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == 1) {
        
        if(self.laundrySegment.selectedSegmentIndex == 0) {
            static NSString *cellIdentifier = @"Cell2";
            LaundryWasherDetailTableViewCell *cell = nil;
            
            if (!cell) {
                cell = [[LaundryWasherDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil available_washers:self.aw unavailable_washers:self.uw];
            }
            
            cell.textLabel.text = @"";
            cell.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1.0];
            cell.accessoryView = nil;
            cell.detailTextLabel.text = @"";
            
            cell.nameLabel.text = self.houseName;
            
            return cell;
        } else {
            
            static NSString *cellIdentifier = @"Cell3";
            LaundryDryerDetailTableViewCell *cell = nil;
            
            if (!cell) {
                cell = [[LaundryDryerDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil available_dryers:self.ad unavailable_dryers:self.ud];
            }
            
            cell.textLabel.text = @"";
            cell.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1.0];
            cell.accessoryView = nil;
            cell.detailTextLabel.text = @"";
            
            cell.nameLabel.text = self.houseName;
            
            return cell;
        }
        

        
    } else {
        static NSString *cellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (!cell)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        
        if(indexPath.row == 0) {
            cell.textLabel.text = @"";
            cell.backgroundColor = [UIColor whiteColor];
            cell.detailTextLabel.text = @"";
            cell.accessoryView = nil;
        } else {
            cell.backgroundColor = [UIColor whiteColor];
            cell.imageView.image = nil;
            UISwitch *switchview = [[UISwitch alloc] initWithFrame:CGRectZero];
            switchview.tag = indexPath.row;
            [switchview addTarget:self action:@selector(switched:) forControlEvents:UIControlEventValueChanged];
            if(self.laundrySegment.selectedSegmentIndex == 0) {
                cell.textLabel.text = [NSString stringWithFormat:@"Washer %lu", indexPath.row-1];
                if([[[self.washerList objectAtIndex:indexPath.row-2] objectForKey:@"available"] boolValue]) {
                    cell.detailTextLabel.text = @"Available";
                    cell.detailTextLabel.textColor = [UIColor greenColor];
                    cell.accessoryView = nil;
                } else {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"Busy - %@", [[self.washerList objectAtIndex:indexPath.row-2] objectForKey:@"time_left"]];
                    cell.accessoryView = switchview;
                    cell.detailTextLabel.textColor = [UIColor redColor];
                }
            } else {
                cell.textLabel.text = [NSString stringWithFormat:@"Dryer %lu", indexPath.row-1];
                if([[[self.dryerList objectAtIndex:indexPath.row-2] objectForKey:@"available"] boolValue]) {
                    cell.detailTextLabel.text = @"Available";
                    cell.detailTextLabel.textColor = [UIColor greenColor];
                    cell.accessoryView = nil;
                } else {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"Busy - %@", [[self.dryerList objectAtIndex:indexPath.row-2] objectForKey:@"time_left"]];
                    cell.detailTextLabel.textColor = [UIColor redColor];
                    if([[[self.dryerList objectAtIndex:indexPath.row-2] objectForKey:@"time_left"] isEqualToString:@"not updating status"]) {
                        cell.accessoryView = nil;
                    } else {
                        cell.accessoryView = switchview;
                    }
                }
            }
        }
        return cell;
    }
    
}

-(void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma Switch Statement

- (void)switched:(id) sender {
    NSIndexPath *path = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
    NSString *text = [self.tableView cellForRowAtIndexPath:path].detailTextLabel.text;
    NSInteger minutes = [[[text componentsSeparatedByString:@" "] objectAtIndex:2] integerValue];
    
    if ([sender isOn]) {
        UILocalNotification *local = [[UILocalNotification alloc] init];
        
        local.fireDate = [NSDate dateWithTimeIntervalSinceNow:minutes*60]; //time in seconds
        local.timeZone = [NSTimeZone defaultTimeZone];
        
        local.alertBody = @"Your laundry machine is free!";
        local.alertAction = @"Okay!";
        
        local.soundName = [NSString stringWithFormat:@"Default.caf"];

        [[UIApplication sharedApplication] scheduleLocalNotification:local];
    } else {
        NSLog(@"?????");
        [sender setOn:NO animated:YES];
    }
    
}

@end
