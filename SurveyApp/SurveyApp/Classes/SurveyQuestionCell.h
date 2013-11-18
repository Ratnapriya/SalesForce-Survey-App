//
//  SurveyQuestionCell.h
//  test1
//
//  Created by Ratna priya Saripalli on 11/10/13.
//  Copyright (c) 2013 myCompany. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SurveyQuestionCell : UITableViewCell

@property (strong, nonatomic) UILabel *questionLabel;
@property (strong, nonatomic) UITextField *responseTxtFld;
@property (strong, nonatomic) NSString *question;
@property (strong, nonatomic) NSString *response;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier question: (NSString *)surveyQuestion;

@end
