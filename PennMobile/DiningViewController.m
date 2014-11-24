
//
//  DiningViewController.m
//  PennMobile
//
//  Created by Sacha Best on 9/9/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import "DiningViewController.h"

@interface DiningViewController ()

@end

/**
 
 TODO: uncomment the code preventing menu code pulls
 
 **/
@implementation DiningViewController

bool usingTempData;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = 100.0f;
    _venues = [[NSMutableDictionary alloc] initWithCapacity:4];
    _days = [[NSMutableSet alloc] initWithCapacity:5];
    _mealTimes = [[NSMutableArray alloc] initWithCapacity:4];
    residential = [[NSMutableArray alloc] init];
    retail = [[NSMutableArray alloc] init];
    _selectedDate = [NSDate date];
    venueJSONFormatter = [[NSDateFormatter alloc] init];
    [venueJSONFormatter setDateFormat:@"yyyy-MM-dd"];
    hoursJSONFormatter = [[NSDateFormatter alloc] init];
    [hoursJSONFormatter setDateFormat:@"HH:mm:ss"];
    roundingFormatter = [[NSDateFormatter alloc] init];
    [roundingFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    mealJSONFormatter = [[NSDateFormatter alloc] init];
    [mealJSONFormatter setDateFormat:@"MM/dd/yyyy"];
    //usingTempData = true;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (void)viewDidAppear:(BOOL)animated {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if (_venues && _venues.count > 0) {
        [_venues removeAllObjects];
        [residential removeAllObjects];
        [retail removeAllObjects];
    }
    [self performSelectorInBackground:@selector(loadFromAPI) withObject:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refresh {
    [[self tableView] reloadData];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of types of dining locaitons
    return 2;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Residential";
            break;
        case 1:
            return @"Retail";
        default:
            break;
    }
    return 0;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of dining halls available
    switch (section) {
        case 0:
            return residential.count;
            break;
        case 1:
            return retail.count;
        default:
            break;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DiningTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"hall" forIndexPath:indexPath];
    if (!cell) {
        cell = [[DiningTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"hall"];

    }
    // This pick from the correct array of dining halls to display on the table
    switch (indexPath.section) {
        case 0:
            cell.venueLabel.text = residential[indexPath.row][@"name"];
            break;
        case 1:
            cell.venueLabel.text = retail[indexPath.row][@"name"];
            //cell.selectionStyle = UITableViewCellSelectionStyleNone;
        default:
            break;
    }
    // Configure the cell...
    if (usingTempData) {
        cell.venueLabel.text = @"University of Pennsylvania Hill House";
        cell.addressLabel.text = @"1000 Sacha St, Best, CA 90210";
    } else {
        //cell.venueLabel.text = _venues[indexPath.row])[kTitleKey];
        //cell.addressLabel.text = _venues[indexPath.row][kAddressKey];
        int open = [self isOpen:cell.venueLabel.text];
        if (open > 0) {
            cell.openLabel.text = @" OPEN NOW ";
            cell.addressLabel.text = [NSString stringWithFormat:@"Currently serving: %@", [self enumToStringTime:open]];
            cell.openLabel.backgroundColor = [UIColor colorWithRed:29/255.0 green:207/255.0 blue:40/255.0 alpha:1.0];
        } else {
            cell.openLabel.text = @" closed ";
            cell.openLabel.backgroundColor = [UIColor grayColor];
            cell.addressLabel.text = [NSString stringWithFormat:@"Next serving: %@", [[self enumToStringTime:open] substringFromIndex:1]];
            // This code shows the regions from the xml to query
        }
    }
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}


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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   /** if (indexPath.section *== 0) { **/
        NSString *venueName = ((DiningTableViewCell *)[tableView cellForRowAtIndexPath:indexPath]).venueLabel.text;
        venueName = [@"University of Pennsylvania " stringByAppendingString:venueName];
        dataForNextView = [self getMealsForVenue:venueName forDate:_selectedDate atMeal:[self isOpen:venueName]];
        if (!dataForNextView || dataForNextView.count == 0) {
            UIAlertView *new = [[UIAlertView alloc] initWithTitle:@"Menu Unavailable" message:@"The menu you requested is not currently available. Please note that we do not get menus for Express and Retail locations :(\nIf you don't like this limitation, please call (215) 555-5555 to complain." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Call", nil];
            [new show];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        else {
            [self performSegueWithIdentifier:@"cellClick" sender:[tableView cellForRowAtIndexPath:indexPath]];
        }
   /* } */
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"cellClick"]) {
        MenuViewController *child = ((MenuViewController *)segue.destinationViewController);
        child.navigationItem.title = currentVenue;
        child.food = dataForNextView;
        child.dates = [self getDates];
        child.source = self;
        child.currentDate = _selectedDate;
        child.currentMeal = _selectedMeal;
    
    }
}


#pragma mark - API-loading

- (BOOL)confirmConnection:(NSData *)data {
    if (!data) {
        UIAlertView *new = [[UIAlertView alloc] initWithTitle:@"Couldn't Connect to API" message:@"We couldn't connect to Penn's API. Please try again later. :(" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [new show];
        return false;
    }
    return true;
}
- (void)loadFromAPI {
    [self loadFromAPIwithTarget:nil selector:nil];
}

- (void)parseAPIMeals:(NSDictionary *)raw selector:(SEL)selector target:(id)target {
    NSArray *currentDay;
    NSMutableDictionary *days = [[NSMutableDictionary alloc] init];
    for (int num = 0; num < ((NSArray *) raw[@"Document"][@"tblMenu"]).count; num++) {
        currentDay = [raw[@"Document"][@"tblMenu"][num] objectForKey:kTableDayPart];
        // Data validation - this works ;;;;;
        // NSLog(@"%@", currentDay[0][@"txtDayPartDescription"]);
        NSString *date = raw[@"Document"][@"tblMenu"][num][@"menudate"];
        if (currentDay)
            [days setObject: currentDay forKey:date];
        [_days addObject:date];
    }
    menuMessage = raw[@"Document"][@"tblMessages"][@"txtNoMenuMessage"];
    currentVenue = raw[@"Document"][@"location"];
    if (days)
        [_venues setObject:days forKey:currentVenue];
    if (target && selector) {
        // Go back to main thread to perform callback
        [target performSelectorOnMainThread:selector withObject:nil waitUntilDone:NO];
    }
}

- (NSDictionary *)loadMealsForVenueIndex:(int)index {
    // TEMP - this code reads from an included sample JSON file
    NSString *path;
    NSData *data;
    if (usingTempData) {
        path = [[NSBundle mainBundle] pathForResource:@"venue_sample" ofType:@"txt"];
        data = [[NSFileManager defaultManager] contentsAtPath:path];
    } else {
        path = [NSString stringWithFormat:@"%@%@", SERVER_ROOT, MEAL_PATH];
        path = [path stringByAppendingFormat:@"%d", [self getIDForVenueWithIndex:index]];
        data = [NSData dataWithContentsOfURL:[NSURL URLWithString:path]];
        if (![self confirmConnection:data])
            return nil;
    }
    NSError *error = [NSError alloc];
    NSDictionary *raw = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    if (!raw || error.code != 0) {
        UIAlertView *new = [[UIAlertView alloc] initWithTitle:@"Couldn't Connect to API" message:@"We couldn't connect to Penn's API. Please try again later. :(" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        NSLog(@"JSON Parse error code: %ld", (long)error.code);
        [new show];
        return nil;
    }
    return raw;
}

- (void)loadFromAPIwithTarget:(id)target selector:(SEL)selector {
    if (![self loadVenues]) {
        return;
    }
    NSDictionary *raw;
    for (int count = 0; count < _mealTimes.count; count++) {
        NSString *menuURL = _mealTimes[count][@"dailyMenuURL"];
        // fix for McCleland bullshit
        if (menuURL && ![menuURL isEqualToString:@""] && ![[menuURL substringFromIndex:[menuURL length]-3] isEqualToString:@"737"]) {
            raw = [self loadMealsForVenueIndex:count];
            if (!raw)
                return;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                [self parseAPIMeals:raw selector:selector target:target];
            });
        }
    }
    [self performSelectorOnMainThread:@selector(hideActivity) withObject:nil waitUntilDone:NO];
    [self refresh];
}
- (void)hideActivity {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}
- (BOOL)loadVenues {
    /** Local Load
    NSString *path = [[NSBundle mainBundle] pathForResource:@"list_sample" ofType:@"txt"];
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:path];
     **/
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[SERVER_ROOT stringByAppendingString:SERVER_PATH]]];
    if (![self confirmConnection:data]) {
        return false;
    }
    NSError *error = [NSError alloc];
    NSDictionary *raw = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    if (error.code != 0) {
        [NSException raise:@"JSON parse error" format:@"%@", error];
    }
    NSLog(@"Venue JSON loaded.");
    _mealTimes = raw[@"document"][@"venue"];
    for (NSDictionary *venue in _mealTimes) {
        if ([venue[@"venueType"] isEqualToString:@"residential"]) {
            [residential addObject:venue];
        } else
            [retail addObject:venue];
    }
    return true;
    /** Unused for now, just using accessor b/c very little restructuring needed
    for (NSDictionary *venueData in venueList) {
        NSMutableDictionary *currentVenue = [[NSMutableDictionary alloc] init];
        [currentVenue setObject:venueData[@"name"] forKey:@"name"];
        for (NSDictionary *date in venueData[@"dateHours"]) {
            [currentVenue setObject:[venueJSONFormatter dateFromString:date[@"date"]] forKey:@"date"];
            NSMutableArray *timesToStore = [[NSMutableArray alloc] init];
            for (NSDictionary *times in date[@"meal"]) {
                NSMutableDictionary *time = [[NSMutableDictionary alloc] init];
                time[@"open"] = [hoursJSONFormatter dateFromString:times[@"open"]];
                time[@"close"] = [hoursJSONFormatter dateFromString:times[@"close"]];
                time[@"type"] = times[@"type"];
                [timesToStore addObject:time];
            }
            [currentVenue setObject:timesToStore forKey:@"meals"];
        }
        [_mealTimes addObject:currentVenue];
    }
    **/
}
- (BOOL)isSameDayWithDate1:(NSDate*)date1 date2:(NSDate*)date2 {
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    
    return [comp1 day]   == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year];
}

- (NSArray *)getMealsForVenue:(NSString *)venue forDate:(NSDate *)date atMeal:(Meal)meal {
    NSMutableArray *toReturn = [[NSMutableArray alloc] init];
    NSDictionary *venueContents = _venues[venue];
    NSArray *mealOptions;
    for (NSString *day in [venueContents allKeys]) {
        NSDate *normalizedDay = [mealJSONFormatter dateFromString:day];
        if ([self isSameDayWithDate1:normalizedDay date2:date]) {
            for (int possibleMeal = 0; possibleMeal < ((NSArray *)venueContents[day]).count; possibleMeal++) {
                NSString *trandlatedMeal = [self enumToStringTime:meal];
                if ([trandlatedMeal rangeOfString:venueContents[day][possibleMeal][@"txtDayPartDescription"]].length != 0) {
                    mealOptions = venueContents[day][possibleMeal][kStation];
                }
            }
            for (int station = 0; station < mealOptions.count; station++) {
                NSMutableDictionary *currentStation = [[NSMutableDictionary alloc] initWithCapacity:3];
                id stationItems = mealOptions[station][@"tblItem"];
                [currentStation setObject:mealOptions[station][@"txtStationDescription"] forKey:@"station"];
                NSMutableArray *food = [[NSMutableArray alloc] init];
                // This is absolutely ridiculous
                // If the station only has 1 item, they don't include it in an array in JSON
                // so the two cases (1 item vs 1+) have to be handled individually
                if ([stationItems isKindOfClass:[NSArray class]]) {
                    for (int item = 0; item < ((NSArray *)stationItems).count; item++) {
                        NSString *description = stationItems[item][@"txtDescription"];
                        NSString *title = stationItems[item][@"txtTitle"];
                        NSDictionary *foodItem = [[NSDictionary alloc] initWithObjectsAndKeys:title, @"title", description, @"description", nil];
                        [food addObject:foodItem];
                    }
                } else {
                    NSString *description = stationItems[@"txtDescription"];
                    NSString *title = stationItems[@"txtTitle"];
                    NSDictionary *foodItem = [[NSDictionary alloc] initWithObjectsAndKeys:title, @"title", description, @"description", nil];
                    [food addObject:foodItem];
                }
                [currentStation setObject:food forKey:@"food"];
                [toReturn addObject:currentStation];
            }
        }
    }
    return toReturn;
}

#pragma mark - Data Accessors

// O(n) :(
- (int)getIDForVenue:(NSString *)venue {
    for (NSDictionary *venue in _mealTimes) {
        if ([self matchVenue:venue[@"name"] withOther:venue]) {
            return [venue[@"id"] intValue];
        }
    }
    return -1;
}
- (NSString *)getVenueByID:(int)identifier {
    for (NSDictionary *venue in _mealTimes) {
        if (identifier == (int)venue[@"id"]) {
            return (NSString *) venue[@"name"];
        }
    }
    [NSException raise:@"Venue ID invalid" format:@"ID passed: %d", identifier];
    return nil;
}
- (int)getIDForVenueWithIndex:(int)index {
    return [_mealTimes[index][@"id"] intValue];
}
- (int)getResidentialVenueID:(int)index {
    return [residential[index][@"id"] intValue];
}
// O(n) :(
- (NSArray *)getDates {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSMutableOrderedSet *asNSDate = [[NSMutableOrderedSet alloc] init];
    for (NSString *day in _days) {
        // Because stupid API doesnt follow standardized date sytem (i.e. pads months with 0)
        if ([day characterAtIndex:0] != '1') {
            NSString* toAdd = [NSString stringWithFormat:@"0%@", day];
            [asNSDate addObject:[dateFormatter dateFromString:toAdd]];
        }
        [asNSDate addObject:[dateFormatter dateFromString:day]];
    }
    return [asNSDate sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [(NSDate *)obj1 compare:(NSDate *)obj2];
    }];
}

// Returns the meal the venue is open for, -1 * the next open meal otherwise
// OOOOOHHHH this implementation is genius!!!
-(Meal)isOpen:(NSString *)venue {
    long shortestDuration = INFINITY;
    Meal closestMeal = -1;
    for (NSDictionary *venueTree in _mealTimes) {
        if ([self matchVenue:venueTree[@"name"] withOther:venue]){
            // in correct venue
            for (NSDictionary *date in venueTree[@"dateHours"]) {
                NSCalendar *calendar = [NSCalendar currentCalendar];
                NSDateComponents *componentsForFirstDate = [calendar components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear fromDate:[NSDate date]];
                NSDateComponents *componentsForSecondDate = [calendar components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear fromDate:[venueJSONFormatter dateFromString: date[@"date"]]];
                if ([componentsForFirstDate year] == [componentsForSecondDate year] &&
                    [componentsForFirstDate month] == [componentsForSecondDate month] &&
                    [componentsForFirstDate day] == [componentsForSecondDate day]) {
                    // in correct day
                    if ([date[@"meal"] isKindOfClass:[NSArray class]]) {
                        for (NSDictionary *mealTime in date[@"meal"]) {
                            componentsForFirstDate = [calendar components:NSCalendarUnitMinute|NSCalendarUnitHour fromDate:[hoursJSONFormatter dateFromString:mealTime[@"open"]]];
                            NSDateComponents *now = [calendar components:NSCalendarUnitMinute|NSCalendarUnitHour fromDate:[NSDate date]];
                            componentsForSecondDate = [calendar components:NSCalendarUnitMinute|NSCalendarUnitHour fromDate:[hoursJSONFormatter dateFromString:mealTime[@"close"]]];
                            long startHour = [componentsForFirstDate hour];
                            long endHour = [componentsForSecondDate hour];
                            if (endHour == 0) endHour = 24;
                            if (startHour == 0) startHour = 24;
                            if (startHour <= [now hour] &&
                                [now hour] <= endHour) {
                                _selectedMeal = [self stringTimeToEnum:mealTime[@"type"]];
                                return _selectedMeal;
                            }
                            // fix for Starbucks (hours rolled over from prev day (open 6am close 2am)
                            else if (startHour == 6 && endHour == 2 && ([now hour] > 6 || [now hour] < 2)) {
                                _selectedMeal = [self stringTimeToEnum:mealTime[@"type"]];
                                return _selectedMeal;
                            }
                        }
                    } else {
                        componentsForFirstDate = [calendar components:NSCalendarUnitMinute|NSCalendarUnitHour fromDate:[hoursJSONFormatter dateFromString:date[@"meal"][@"open"]]];
                        NSDateComponents *now = [calendar components:NSCalendarUnitMinute|NSCalendarUnitHour fromDate:[NSDate date]];
                        componentsForSecondDate = [calendar components:NSCalendarUnitMinute|NSCalendarUnitHour fromDate:[hoursJSONFormatter dateFromString:date[@"meal"][@"open"]]];
                        long startHour = [componentsForFirstDate hour];
                        long endHour = [componentsForSecondDate hour];
                        if (endHour == 0) endHour = 24;
                        if (startHour == 0) startHour = 24;
                        if (startHour <= [now hour] &&
                            [now hour] <= endHour) {
                            _selectedMeal = [self stringTimeToEnum:date[@"meal"][@"type"]];
                            return _selectedMeal;
                        }
                        // fix for Starbucks (hours rolled over from prev day (open 6am close 2am)
                        else if (startHour == 6 && endHour == 2 && ([now hour] > 6 || [now hour] < 2)) {
                            _selectedMeal = [self stringTimeToEnum:date[@"meal"][@"type"]];
                            return _selectedMeal;
                        }
                    }
                }
            }
            // at this point we know this venue has nothing open
            // now we have to go through again and find nearest starting time
            for (NSDictionary *date in venueTree[@"dateHours"]) {
                NSString *currentDay = date[@"date"];
                if ([date[@"meal"] isKindOfClass:[NSArray class]]) {
                    for (NSDictionary *meal in date[@"meal"]) {
                        NSDate *mealStart = [roundingFormatter dateFromString:[currentDay stringByAppendingFormat:@" %@", meal[@"open"]]];
                        long interval = [mealStart timeIntervalSinceNow];
                        if (interval > 0 && interval < shortestDuration) {
                            shortestDuration = interval;
                            closestMeal = -1 * [self stringTimeToEnum:meal[@"type"]];
                        }
                    }
                } else {
                    NSDate *mealStart = [roundingFormatter dateFromString:[currentDay stringByAppendingFormat:@" %@", date[@"meal"][@"open"]]];
                    long interval = [mealStart timeIntervalSinceNow];
                    if (interval > 0 && interval < shortestDuration) {
                        shortestDuration = interval;
                        closestMeal = -1 * [self stringTimeToEnum:date[@"meal"][@"type"]];
                    }
                }
            }
        }
    }
    _selectedMeal = closestMeal;
    return closestMeal;
}
#pragma mark - Global Helpers

-(Meal)stringTimeToEnum:(NSString *)mealTime {
    NSString *upper = [mealTime uppercaseString];
    if ([upper isEqualToString:@"BREAKFAST"]) {
        return Breakfast;
    } else if ([upper isEqualToString:@"BRUNCH"]) {
        return Brunch;
    } else if ([upper isEqualToString:@"LUNCH"]) {
        return Lunch;
    } else if ([upper isEqualToString:@"LITE LUNCH"]) {
        return LiteLunch;
    } else if ([upper isEqualToString:@"DINNER"]) {
        return Dinner;
    } else if ([upper isEqualToString:@"EXPRESS"]) {
        return Express;
    } else if ([upper isEqualToString:@"ALL"]) {
        return All;
    } else if ([upper isEqualToString:@"RETAIL"]) {
        return Retail;
    } else if ([upper isEqualToString:@"MEAL EQUIVALENCY"]) {
        return MealEquivalency;
    } else if ([upper isEqualToString:@"LITE BREAKFAST"]) {
        return LiteBreakfast;
    } else {
        [NSException raise:@"Invalid meal type" format:@"type given was %@", mealTime];
        return -1;
    }
}
-(NSString *)enumToStringTime:(Meal)mealTime {
    if (mealTime == Breakfast) {
        return @"Breakfast";
    } else if (mealTime == Lunch) {
        return @"Lunch";
    } else if (mealTime == LiteLunch) {
        return @"Lite Lunch";
    }  else if (mealTime == Brunch) {
        return @"Brunch";
    } else if (mealTime == Dinner) {
        return @"Dinner";
    } else if (mealTime == Express) {
        return @"Express";
    } else if (mealTime == All) {
        return @"All";
    } else if (mealTime == Retail) {
        return @"Retail";
    } else if (mealTime == MealEquivalency) {
        return @"Meal Equivalency";
    } else if (mealTime == LiteBreakfast) {
        return @"Lite Breakfast";
    } else {
        if (fabs(mealTime) < 9)
            return [@"c" stringByAppendingString:[self enumToStringTime:(-1 * mealTime)]];
        else {
            [NSException raise:@"Invalid meal type" format:@"type given was %ld", mealTime];
            return nil;
        }
    }
}
-(bool)matchVenue:(NSString *)one withOther:(NSString *)two {
    return [[one uppercaseString] rangeOfString:[two uppercaseString]].length != 0 || [[two uppercaseString] rangeOfString:[one uppercaseString]].length != 0;
}


@end
