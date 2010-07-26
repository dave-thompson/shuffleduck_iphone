//
//  ManualTable.m
//  ShuffleDuck
//
//  Created by Dave Thompson on 3/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ManualTableViewController.h"
#import "FeedbackViewController.h"
#import "ManualPageViewController.h"

@implementation ManualTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	listOfItems = [[NSMutableArray alloc] init];
	
	NSArray *decksArray = [NSArray arrayWithObjects:@"Library Screen", @"Deck Summary Screen", nil];
	NSDictionary *decksDict = [NSDictionary dictionaryWithObject:decksArray forKey:@"Items"];
	
	NSArray *studyModesArray = [NSArray arrayWithObjects:@"Learn", @"Test", @"Reference", nil];
	NSDictionary *studyModesDict = [NSDictionary dictionaryWithObject:studyModesArray forKey:@"Items"];
	
	NSArray *feedbackArray = [NSArray arrayWithObjects:@"Give Feedback", nil];
	NSDictionary *feedbackDict = [NSDictionary dictionaryWithObject:feedbackArray forKey:@"Items"];

	[listOfItems addObject:decksDict];
	[listOfItems addObject:studyModesDict];
	[listOfItems addObject:feedbackDict];
	
	//Set the title
	self.navigationItem.title = @"Manual";
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	if (section == 0)
		return @"Decks";
	else if (section == 1)
		return @"Study Modes";
	else
		return @"Feedback";
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

	return [listOfItems count];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSDictionary *dictionary = [listOfItems objectAtIndex:section];
	NSArray *array = [dictionary objectForKey:@"Items"];
	return [array count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
	}
	
	// Set up the cell...
	
	//First get the dictionary object
	NSDictionary *dictionary = [listOfItems objectAtIndex:indexPath.section];
	NSArray *array = [dictionary objectForKey:@"Items"];
	NSString *cellValue = [array objectAtIndex:indexPath.row];
	
	#ifdef __IPHONE_3_0
		// if compiling against iPhone OS 3.x or higher
		cell.textLabel.text = cellValue;
	#else
		// if compiling against iPhone OS 2.x
		cell.text = cellValue;
	#endif
	
	
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	//Get the selected country
	
	NSDictionary *dictionary = [listOfItems objectAtIndex:indexPath.section];
	NSArray *array = [dictionary objectForKey:@"Items"];
	NSString *selectedOption = [array objectAtIndex:indexPath.row];
	
	
	if ([selectedOption isEqualToString:@"Give Feedback"])
	{
		// push the feedback controller
		[self.navigationController pushViewController:[FeedbackViewController sharedInstance] animated:YES];
	}
	else
	{
		// get manual page file path
		NSString *fileName = [[selectedOption stringByReplacingOccurrencesOfString:@" " withString:@""] stringByAppendingString:@".html"];
		NSString *filePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileName];
		
		// push the appropriate manual page
		ManualPageViewController *manualPageViewController = [[ManualPageViewController alloc] initWithNibName:@"ManualPageView" bundle:nil];
		manualPageViewController.filePath = filePath;
		manualPageViewController.title = selectedOption;
		[self.navigationController pushViewController:manualPageViewController animated:YES];
		[manualPageViewController release];
		manualPageViewController = nil;
	}	
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [super dealloc];
	[listOfItems release];
}


@end

