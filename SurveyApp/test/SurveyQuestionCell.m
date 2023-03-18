//
//  SurveyQuestionCell.m
//  test1
//
//  Created by Ratna priya Saripalli on 11/10/13.
//  Copyright (c) 2013 myCompany. All rights reserved.
//

#import "SurveyQuestionCell.h"
#define QUES_FONT_SIZE 17
#define QUES_LBL_X_OFFSET 15
#define QUES_LBL_Y_OFFSET 7
#define QUES_LBL_WIDTH 650
#define QUES_LBL_HEIGHT 40
#define QUES_LBL_PADDING 10


@implementation SurveyQuestionCell 

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier question: (NSString *)surveyQuestion
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.questionLabel = [[UILabel alloc]initWithFrame:CGRectMake(QUES_LBL_X_OFFSET,QUES_LBL_Y_OFFSET,QUES_LBL_WIDTH,QUES_LBL_HEIGHT)];
        [self.questionLabel setText:surveyQuestion];
        [self.questionLabel setFont:[UIFont boldSystemFontOfSize:QUES_FONT_SIZE]];
        [self.contentView addSubview:self.questionLabel];
        self.responseTxtFld = [[UITextField alloc]initWithFrame:CGRectMake(QUES_LBL_X_OFFSET,QUES_LBL_Y_OFFSET+QUES_LBL_HEIGHT+QUES_LBL_PADDING,QUES_LBL_WIDTH,QUES_LBL_HEIGHT)];
        self.responseTxtFld.layer.borderWidth = 2;
        self.responseTxtFld.layer.borderColor = [[UIColor blackColor] CGColor];
        [self.responseTxtFld setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:self.responseTxtFld];

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
