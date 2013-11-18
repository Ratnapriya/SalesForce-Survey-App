//
//  DetailTableViewController.m
//  test1
//
//  Created by Ratna priya Saripalli on 11/10/13.
//  Copyright (c) 2013 myCompany. All rights reserved.
//

#import "DetailTableViewController.h"
#import "SurveyQuestionCell.h"
#import "SFRestAPI+Blocks.h"
#define RESPONSE_TEXTFIELD_TAG 10
#define LBL_X_OFFSET 60
#define LBK_Y_OFFSET 45
#define LBL_WIDTH 150
#define LBL_HEIGHT 25
#define HDR_HEIGHT 275
#define LBL_PADDING_X 250
#define LBL_PADDING_Y 20
#define LINE_WIDTH 250
#define LINE_Y_OFFSET 250
#define LINE_X_OFFSET 180
#define LINE_HEIGHT 2




@interface DetailTableViewController ()

@end

@implementation DetailTableViewController


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //Fetch all the questions when the controller is initialized as these are the same for all contacts
        [Contact fetchQuestions];
        __block __weak id observer = [[NSNotificationCenter defaultCenter] addObserverForName:QUESTIONS_DATA_PARSED
                                                                                       object:nil
                                                                                        queue:[NSOperationQueue mainQueue]
                                                                                   usingBlock:^(NSNotification *notification) {
                                                                                       [loadingIndicator   stopAnimating];
                                                                                       [self updateView];
                                                                                       [self.tableView reloadData];
                                                                                       [[NSNotificationCenter defaultCenter] removeObserver:observer name:QUESTIONS_DATA_PARSED object:nil];
                                                                                       if(self.contactObj)
                                                                                           [self.contactObj fetchContact];
                                                                                   }];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(downloadFailed:)
                                                     name:DOWNLOAD_FAILED
                                                   object:nil];

        
    }
    return self;
}


/**
 * Fetches contact data from server and updates the UI
 * @param none
 * @return none
 */
-(void) fetchedData {
    [self updateView];
}

/**
 * Handles a server error notification and updates the user
 * @param notification object
 * @return none
 */

-(void)downloadFailed: (NSNotification*)receivedNotification {
    
    [[[UIAlertView alloc] initWithTitle:@"Server Error"
                                message:[receivedNotification.userInfo objectForKey:@"msg"]
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableHeaderView = [self headerView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fetchedData)
                                                 name:DATA_PARSED
                                               object:nil];
    loadingIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
   // CGRect visibleRect = self.tableView.bounds;
    [loadingIndicator setFrame:CGRectMake(0.0,0.0,40.0,40.0)];
    loadingIndicator.center = self.tableView.tableHeaderView.center ;
    [self.tableView addSubview:loadingIndicator];
    [loadingIndicator startAnimating];
    
 }



-(void)setContactObj:(Contact *)contactObj {
    
    if (_contactObj != contactObj) {
        _contactObj = contactObj;
        //Fetch the contact data
        [_contactObj fetchContact];
    }

}


/**
 * Updates the view with the data recieved from server
 * @param  none
 * @return none
 */
-(void)updateView
{
    if (self.contactObj) {
        self.title = self.contactObj.name;
        NSString *lblStr = self.contactObj.email;
        
        CGSize expectedLabelSize;
        
        if(lblStr) {
            expectedLabelSize = [self sizeForText:(NSString *)lblStr];
            self.emailDescriptionLabel.frame = CGRectMake(self.emailDescriptionLabel.frame.origin.x, self.emailDescriptionLabel.frame.origin.y, expectedLabelSize.width, expectedLabelSize.height);
        }
        self.emailDescriptionLabel.font=[UIFont systemFontOfSize:12];
        self.emailDescriptionLabel.text=lblStr;
        
        lblStr = self.contactObj.accountName;
        if(lblStr) {
            expectedLabelSize = [self sizeForText:lblStr];
            self.accountDescriptionLabel.frame = CGRectMake(self.accountDescriptionLabel.frame.origin.x, self.accountDescriptionLabel.frame.origin.y, expectedLabelSize.width, expectedLabelSize.height);
        }
        self.accountDescriptionLabel.font=[UIFont systemFontOfSize:12];
        self.accountDescriptionLabel.text=lblStr;
        
        
        lblStr = self.contactObj.title;
        if(lblStr) {
            expectedLabelSize = [self sizeForText:lblStr];
            self.titleDescriptionLabel.frame = CGRectMake(self.titleDescriptionLabel.frame.origin.x, self.titleDescriptionLabel.frame.origin.y, expectedLabelSize.width, expectedLabelSize.height);
        }
        self.titleDescriptionLabel.font=[UIFont systemFontOfSize:12];
        self.titleDescriptionLabel.text=lblStr;
        
        self.phDescriptionLabel.text = self.contactObj.phone;
        [self.tableView reloadData];
        
    }
    
}


/**
 * Calculates the size for a label based a string size with the font
 * @param String
 * @return size of the label
 */

-(CGSize) sizeForText : (NSString *)lblString
{
    
    CGSize maximumLabelSize = CGSizeMake(LBL_WIDTH+LBL_PADDING_X,LBL_HEIGHT+LBL_PADDING_Y);
    CGSize expectedLabelSize = [lblString sizeWithFont:[UIFont systemFontOfSize:12]
                                     constrainedToSize:maximumLabelSize
                                         lineBreakMode:NSLineBreakByCharWrapping];
    
    return expectedLabelSize;
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.contactObj.questionAnswers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    SurveyQuestionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    SurveyQuestionAnswer *qa = [self.contactObj.questionAnswers objectAtIndex:indexPath.row];
    if (cell == nil) {
        cell = [[SurveyQuestionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier question:qa.questionObj.question];
        [cell.responseTxtFld setTag:RESPONSE_TEXTFIELD_TAG*(indexPath.row + 1)];
        [cell.responseTxtFld setDelegate:self];
        cell.backgroundColor=[UIColor groupTableViewBackgroundColor];
    }
    [cell.responseTxtFld setText:qa.response];
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110;
}

-(UIView *) headerView {
    NSInteger frameWidth = self.tableView.frame.size.width;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frameWidth, HDR_HEIGHT)];
    
    
    //Add Account Label
    UILabel *acctLabel = [[UILabel alloc]initWithFrame:CGRectMake(LBL_X_OFFSET,LBK_Y_OFFSET,LBL_WIDTH,LBL_HEIGHT)];
    [acctLabel setText:@"Account"];
    [acctLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [view addSubview:acctLabel];
    
    //Add Account Description Label
    self.accountDescriptionLabel = [[UILabel alloc]initWithFrame:CGRectMake(LBL_X_OFFSET,LBK_Y_OFFSET+acctLabel.frame.size.height+LBL_PADDING_Y,LBL_WIDTH,LBL_HEIGHT)];
    [self.accountDescriptionLabel setText:@""];
    [view addSubview:self.accountDescriptionLabel];
    
    //Add Title Label
    UILabel *titlelabel = [[UILabel alloc]initWithFrame:CGRectMake(LBL_X_OFFSET+acctLabel.frame.size.width+LBL_PADDING_X,LBK_Y_OFFSET,LBL_WIDTH,LBL_HEIGHT)];
    [titlelabel setText:@"Title"];
    [titlelabel setFont:[UIFont boldSystemFontOfSize:17]];
    [view addSubview:titlelabel];
    
    //Add Title Description Label
    self.titleDescriptionLabel = [[UILabel alloc]initWithFrame:CGRectMake(titlelabel.frame.origin.x,titlelabel.frame.origin.y+titlelabel.frame.size.height+LBL_PADDING_Y,LBL_WIDTH,LBL_HEIGHT)];
    [self.titleDescriptionLabel setText:@""];
    self.titleDescriptionLabel.font=[UIFont systemFontOfSize:12];
    [view addSubview:self.titleDescriptionLabel];

    //Add Email Label
    UILabel *emaillabel = [[UILabel alloc]initWithFrame:CGRectMake(LBL_X_OFFSET,self.accountDescriptionLabel.frame.origin.y+LBL_HEIGHT+2*LBL_PADDING_Y,LBL_WIDTH,LBL_HEIGHT)];
    [emaillabel setText:@"Email"];
    [emaillabel setFont:[UIFont boldSystemFontOfSize:17]];
    [view addSubview:emaillabel];
    
    //Add Email Description Label
    self.emailDescriptionLabel = [[UILabel alloc]initWithFrame:CGRectMake(LBL_X_OFFSET,emaillabel.frame.origin.y+LBL_HEIGHT+LBL_PADDING_Y,LBL_WIDTH,LBL_HEIGHT)];
    [self.emailDescriptionLabel setText:@""];
    [view addSubview:self.emailDescriptionLabel];
    
    //Add Phone Label
     UILabel *phlabel = [[UILabel alloc]initWithFrame:CGRectMake(LBL_X_OFFSET+emaillabel.frame.size.width+LBL_PADDING_X,self.titleDescriptionLabel.frame.origin.y+LBL_HEIGHT+2*LBL_PADDING_Y,LBL_WIDTH,LBL_HEIGHT)];
    [phlabel setText:@"Phone"];
    [phlabel setFont:[UIFont boldSystemFontOfSize:17]];
    [view addSubview:phlabel];
    
    //Add Phone Description Label
    self.phDescriptionLabel = [[UILabel alloc]initWithFrame:CGRectMake(phlabel.frame.origin.x,phlabel.frame.origin.y+phlabel.frame.size.height+LBL_PADDING_Y,LBL_WIDTH,LBL_HEIGHT)];
    [self.phDescriptionLabel setText:@""];
    self.phDescriptionLabel.font=[UIFont systemFontOfSize:12];
    [view addSubview:self.phDescriptionLabel];

    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(LINE_X_OFFSET,self.phDescriptionLabel.frame.origin.y+LBL_HEIGHT+2*LBL_PADDING_Y,LINE_WIDTH,LINE_HEIGHT)];

    [line setBackgroundColor:[UIColor blackColor]];
    [view addSubview:line];
    
    return view;

    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 100.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if(section == 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 600, 50)];
        self.saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.saveButton  setFrame:CGRectMake(550, 30, 100, 30)];
        [self.saveButton setTitle:@"Submit" forState:UIControlStateNormal];
        [self.saveButton addTarget:self action:@selector(saveResponses) forControlEvents:UIControlEventTouchDown];
        [view addSubview:self.saveButton];
        [self.saveButton setEnabled:NO];
        return  view;

    }
    return nil;

}

/**
* Saves the user responses to server
* @param none
* @return none
*/

-(void) saveResponses {
    UIAlertView *saveAlert = [[UIAlertView alloc]initWithTitle:@""
                                                        message:@"Saving..."
                                                       delegate:nil
                                              cancelButtonTitle:nil otherButtonTitles:nil];
     [saveAlert show];
    __block __weak id observer = [[NSNotificationCenter defaultCenter] addObserverForName:SURVEYQUESTIONS_RESPONSE_SAVED
                                                        object:nil
                                                        queue:[NSOperationQueue mainQueue]
                                                    usingBlock:^(NSNotification *notification) {
                                                        [saveAlert dismissWithClickedButtonIndex:0 animated:YES];
                                                        [[NSNotificationCenter defaultCenter] removeObserver:observer name:SURVEYQUESTIONS_RESPONSE_SAVED object:nil];
                                                        
                                                    }];
    [self.contactObj updateContactResponses];
    
   }


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    int row = textField.tag/RESPONSE_TEXTFIELD_TAG-1;
    SurveyQuestionAnswer *qa = [self.contactObj.questionAnswers objectAtIndex:row];
    if(!qa.response && textField.text.length==0)
        return;
      if(![qa.response isEqualToString:textField.text]) {
          qa.isDirty = YES;
          qa.response = textField.text;
          [self.saveButton setEnabled:YES];
        }
}

-(void) dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DOWNLOAD_FAILED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DATA_PARSED object:nil];

}


@end
