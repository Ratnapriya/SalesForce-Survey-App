/*
 Copyright (c) 2011, salesforce.com, inc. All rights reserved.
 
 Redistribution and use of this software in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of
 conditions and the following disclaimer in the documentation and/or other materials provided
 with the distribution.
 * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
 endorse or promote products derived from this software without specific prior written
 permission of salesforce.com, inc.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


#import "RootViewController.h"

#import "SFRestAPI+Blocks.h"
#import "SFRestRequest.h"
#define CONTACT_PAGE_SIZE 30

@implementation RootViewController

@synthesize dataRows;


#pragma mark Misc

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    self.dataRows = nil;
}

- (NSMutableArray *) dataRows {
    if(!dataRows)
        dataRows = [[NSMutableArray alloc]init];
    return dataRows;

}


#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"My Contact Surveys App";
    self.detailViewController = (DetailTableViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    loadingIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    loadingIndicator.center = self.tableView.center ;
    [self.tableView addSubview:loadingIndicator];
    [loadingIndicator startAnimating];
    loadingIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [loadingIndicator startAnimating];
    
    NSString *query = [NSString stringWithFormat:@"SELECT name, Id FROM Contact limit %d", CONTACT_PAGE_SIZE];
    [self fetchData:query];
 }


- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataRows count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   static NSString *CellIdentifier = @"CellIdentifier";

   // Dequeue or create a cell of the appropriate type.
    UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];

    }
	UIImage *image = [UIImage imageNamed:@"icon.png"];
	cell.imageView.image = image;

	// Configure the cell to show the data.
	NSDictionary *obj = [dataRows objectAtIndex:indexPath.row];
	cell.textLabel.text =  [obj objectForKey:@"Name"];

	//this adds the arrow to the right hand side.
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

	return cell;

}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y == scrollView.contentSize.height - scrollView.frame.size.height) {
        
        [self fetchMoreData];
    }
}


/**
 * Executes a query to get all the contact names and updates the UI
 * @param string
 * @return none
 */
- (void)fetchData : (NSString *)query {
    
    
    [[SFRestAPI sharedInstance] performSOQLQuery:query
                                       failBlock:^(NSError *error) {
                                           NSLog(@"performSOQLQuery Error -- %@", [error description]);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               [[[UIAlertView alloc] initWithTitle:@"Server Error"
                                                                           message:@"Error downloading contact names."
                                                                          delegate:nil
                                                                 cancelButtonTitle:@"OK"
                                                                 otherButtonTitles:nil] show];

                                            });
                                       }
                                   completeBlock:^(NSDictionary *results) {
                                       
                                       if([loadingIndicator isAnimating])
                                           [loadingIndicator stopAnimating];
                                       NSArray *records = [results objectForKey:@"records"];
                                       NSLog(@"request:didLoadResponse: #records: %d", records.count);
                                       [self.dataRows addObjectsFromArray:records];
                                       
                                       //Save the next record url returned in this record for pagination.
                                       if([results objectForKey:@"nextRecordsUrl"] != [NSNull null])
                                           nextRecordsURL = [results objectForKey:@"nextRecordsUrl"];
                                       
                                       if(self.detailViewController.contactObj == nil) {
                                           NSDictionary *d = [dataRows objectAtIndex:0];
                                           Contact *contact = [[Contact alloc]initWithContactName:[d objectForKey:@"name"] Id:[d objectForKey:@"Id"]];
                                           self.detailViewController.contactObj = contact;
                                       }
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           [loadingIndicator stopAnimating];
                                           [self.tableView reloadData];
                                           [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:0];
                                           
                                       });
                                   }];


    }




/**
 * Fetches more data from server if the last row is visible.
 * @param none
 * @return none
 */
- (void)fetchMoreData
{
    
    if ([dataRows count] > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        NSIndexPath *lastRow = [visiblePaths lastObject];
        
        // Check whether or not the very last row is visible.
        NSInteger numberOfSections = [self.tableView numberOfSections];
        NSInteger lastRowSection = [lastRow section];
        NSInteger lastRowRow = [lastRow row];
        NSInteger numberOfRowsInSection = [self.tableView numberOfRowsInSection:lastRowSection];
        
        if (lastRowSection == numberOfSections - 1 &&
            lastRowRow== numberOfRowsInSection - 1) {
            
            if (nextRecordsURL) { // if nextRecordsURL is not nil then there is more data to be downloaded.
                [self fetchNextPage];
            }
            
        }
    }
}


-(void) fetchNextPage {
    
    if(nextRecordsURL)
        [self fetchData:nextRecordsURL];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        NSDictionary *d = [dataRows objectAtIndex:indexPath.row];
        Contact *contact = [[Contact alloc]initWithContactName:[d objectForKey:@"name"] Id:[d objectForKey:@"Id"]];
        self.detailViewController.contactObj = contact;
    }
}


@end
