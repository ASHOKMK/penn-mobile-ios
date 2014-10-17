//
//  RegistrarTableViewController.m
//  PennMobile
//
//  Created by Sacha Best on 9/23/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import "RegistrarTableViewController.h"

@interface RegistrarTableViewController ()

@end

@implementation RegistrarTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // to dismiss the keyboard when the user taps on the table
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [self.view addGestureRecognizer:tap];
    activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.center = CGPointMake(self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0);
    activityIndicator.hidesWhenStopped = YES;
    [self.view addSubview: activityIndicator];
    _searchBar.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissKeyboard:(id)sender {
    [_searchBar resignFirstResponder];
}
#pragma mark - API

-(NSSet *)searchForName:(NSString *)name {
    // This is a set because multiple terms qre queried and we don't want duplicate results
    NSMutableSet *results = [[NSMutableSet alloc] init];
    if ([name containsString:@" "]) {
        NSArray *split = [name componentsSeparatedByString:@" "];
        for (NSString *queryTerm in split) {
            [results addObjectsFromArray:[self queryAPI:queryTerm]];
        }
    }
    return results;
}

-(NSArray *)queryAPI:(NSString *)term {
    NSData *result = [NSData dataWithContentsOfURL:[NSURL URLWithString:[REGISTRAR_PATH stringByAppendingString:term] relativeToURL:[NSURL URLWithString:SERVER_ROOT]]];
    NSError *error;
    NSDictionary *returned = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingMutableLeaves error:&error];
    if (error.code != 0) {
        [NSException raise:@"JSON parse error" format:@"%@", error];
    }
    return returned[@"courses"];
}

-(void)importData:(NSArray *)raw {
    NSMutableSet *tempSet = [[NSMutableSet alloc] initWithCapacity:raw.count];
    for (NSDictionary *courseData in raw) {
        Course *new = [[Course alloc] init];
        new.identifier = courseData[@"_id"];
        new.dept = courseData[@"course_department"];
        new.title = courseData[@"course_title"];
        new.courseNum = courseData[@"course_number"];
        new.credits = courseData[@"credits"];
        new.sectionNum = courseData[@"section_number"];
        new.type = courseData[@"type"];
        new.times = courseData[@"times"];
        new.building = courseData[@"building"];
        new.roomBum = courseData[@"roomNumber"];
        NSMutableArray *profs = [[NSMutableArray alloc] init];
        for (NSDictionary *prof in courseData[@"prof"]) {
            [profs addObject:prof[@"name"]];
        }
        new.professors = [profs copy];
        [tempSet addObject:new];
    }
    _courses = [tempSet allObjects];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _courses.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RegistrarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"class" forIndexPath:indexPath];
    Course *inQuestion = _courses[indexPath.row];
    cell.detailTextLabel.text = inQuestion.title;
    cell.textLabel.text = inQuestion.courseNum;
    CGRect cellFrame = cell.textLabel.frame;
    cell.textLabel.frame = CGRectMake(cellFrame.origin.x, cellFrame.origin.y, 20.0f, cellFrame.size.height);
    return cell;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [_searchBar resignFirstResponder];
    [activityIndicator startAnimating];
    [self performSelectorInBackground:@selector(queryHandler:) withObject:searchBar.text];
}
- (void)queryHandler:(NSString *)search {
    [self importData:[self queryAPI:search]];
    [self performSelectorOnMainThread:@selector(reloadView) withObject:nil waitUntilDone:NO];
}
- (void)reloadView {
    [self.tableView reloadData];
    [activityIndicator stopAnimating];
}
/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end