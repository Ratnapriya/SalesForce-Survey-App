//
//  Contact.h
//  test1
//
//  Created by Ratna priya Saripalli on 11/11/13.
//  Copyright (c) 2013 myCompany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SurveyQuestionAnswer.h"
#define DATA_PARSED @"data_parsed"
#define QUESTIONS_DATA_PARSED @"questions_data_parsed"
#define SURVEYQUESTIONS_RESPONSE_SAVED @"response_saved"
#define DOWNLOAD_FAILED @"download_failed"



@interface Contact : NSObject {
    
    NSString *name;
    NSString *Id;
    NSString *accountName;
    NSString *phone;
    NSString *email;
    NSString *title;
}

@property (nonatomic, strong)NSString *accountName;
@property (nonatomic, strong)NSString *phone;
@property (nonatomic, strong)NSString *email;
@property (nonatomic, strong)NSString *title;
@property (nonatomic, strong)NSString *name;
@property (nonatomic, strong)NSString *Id;
@property (nonatomic, strong)NSMutableArray *questionAnswers;



-(id)initWithContactName :(NSString *)name Id:(NSString *)Id;
+(void) fetchQuestions;
-(void) fetchContact;
-(void)updateContactResponses;
+(NSMutableArray *)questions;
+(void) parseQuestionData :(NSArray *)data;
-(void) parseContact :(NSDictionary *)d;
-(NSArray *) apiNames;




@end
