//
//  DetailTableViewController.h
//  test1
//
//  Created by Ratna priya Saripalli on 11/10/13.
//  Copyright (c) 2013 myCompany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFRestAPI.h"
#import "Contact.h"

@interface DetailTableViewController : UITableViewController<UISplitViewControllerDelegate, SFRestDelegate, UITextFieldDelegate> {
    
    UIActivityIndicatorView *loadingIndicator;
}

@property (strong, nonatomic) Contact *contactObj;


@property (strong, nonatomic) IBOutlet UILabel *accountDescriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *emailDescriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *phDescriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleDescriptionLabel;
@property (strong, nonatomic) UIButton *saveButton;


-(void)updateView;
-(void) fetchedData;
-(void)saveResponses;
-(CGSize) sizeForText : (NSString *)lblString;



@end
