//
//  Contact.m
//  test1
//
//  Created by Ratna priya Saripalli on 11/11/13.
//  Copyright (c) 2013 myCompany. All rights reserved.
//


#import "Contact.h"
#import "SFRestAPI+Blocks.h"


static NSMutableArray *questions;

@implementation Contact
@synthesize email, accountName, title, phone, Id, name, questionAnswers;


-(id)init {
    self = [super init];
    if(self) {
     }
    return self;
}

-(id)initWithContactName :(NSString *)newName Id:(NSString *)newId {
    
    self = [self init];
    if(self) {
        self.name = newName;
        self.Id = newId;
    }
    return self;
}

+(NSMutableArray *)questions {
    
    return questions;
}

/**
 * Executes an update is the question is marked isDirty and posts a notification for the observers
 * Parses the data and posts a notification for observer
 * @param none
 * @return none
 */
-(void)updateContactResponses  {
    NSMutableDictionary *fields = [[NSMutableDictionary alloc]init];

    for(SurveyQuestionAnswer *qa in self.questionAnswers) {
        if(qa.isDirty)
            [fields setObject:qa.response forKey:qa.questionObj.apiName];
    }
    
    [[SFRestAPI sharedInstance] performUpdateWithObjectType:@"Contact" objectId:self.Id fields:fields
                                                  failBlock:^(NSError *e) {
                                                      NSLog(@"performUpdateWithObjectType Error -- %@", [e description]);
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          
                                                          [[NSNotificationCenter defaultCenter] postNotificationName:DOWNLOAD_FAILED object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Failed to submit Response.", @"msg", nil]];
                                                      });
                                                      
                                                  }
                                              completeBlock:^(NSDictionary *results) {
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      [[NSNotificationCenter defaultCenter] postNotificationName:SURVEYQUESTIONS_RESPONSE_SAVED object:nil];
                                                      
                                                  });
                                              }];


}


/**
 * Executes a decribeWithobject for Contact type
 * Parses the data and posts a notification for observer
 * @param none
 * @return none
 */
+(void) fetchQuestions {
    if(questions)
        return;
    
     
    [[SFRestAPI sharedInstance] performDescribeWithObjectType:@"Contact"
                                                    failBlock:^(NSError *e) {
                                                        NSLog(@"Error %@", [e description]);
                                                        dispatch_sync(dispatch_get_main_queue(), ^{
                                                            [[NSNotificationCenter defaultCenter] postNotificationName:DOWNLOAD_FAILED object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Questions Data download failed.", @"msg", nil]];
                                                            });
                                                    }
                                                completeBlock:^(NSDictionary *results) {
                                                    NSArray *arr = [results objectForKey:@"fields"];
                                                    NSLog(@"fields %@", arr);
                                                    NSArray* filt = [arr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name contains 'Question_'"]];
                                                    NSLog(@"filtered array= %@", filt);
                                                    [self parseQuestionData:filt];
                                                    dispatch_sync(dispatch_get_main_queue(), ^{
                                                           [[NSNotificationCenter defaultCenter] postNotificationName:QUESTIONS_DATA_PARSED object:nil];

                                                    });
                                                    
                                                }];
    
    
}

/**
 * Parses Questions data and populates the questions array with SurveyQuestion object
 * @param dictionary of JSON data
 * @return none
 */
+(void) parseQuestionData :(NSArray *)data {
    
    if(!questions)
        questions = [[NSMutableArray alloc]init];
    for(NSDictionary *d in data) {
        SurveryQuestion *q = [[SurveryQuestion alloc]init];
        if([d objectForKey:@"name"] != [NSNull null])
            q.apiName = [d objectForKey:@"name"];
        if([d objectForKey:@"inlineHelpText"] != [NSNull null])
            q.question = [d objectForKey:@"inlineHelpText"];
        [questions addObject:q];
    }
}


/**
 * Executes a RetrieveWithObject for the type Contact
 * Parses the recieved data and posts a notification for observers
 * @param none *
 * @return none
 */

-(void) fetchContact {
    
    NSMutableArray *fields = [NSMutableArray arrayWithObjects:@"Contact.Account.Name", @"Email", @"Title", @"Phone", nil];
    [fields addObjectsFromArray:[self apiNames]];
   
    [[SFRestAPI sharedInstance] performRetrieveWithObjectType:@"Contact"
                                                     objectId:self.Id
                                                    fieldList:fields
                                                    failBlock:^(NSError *e) {
                                                        NSLog(@"Error = %@", e);
                                                        dispatch_async(dispatch_get_main_queue(), ^{

                                                        [[NSNotificationCenter defaultCenter] postNotificationName:DOWNLOAD_FAILED object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Contact data download failed.", @"msg", nil]];
                                                    });

                                                     }
                                                completeBlock:^(NSDictionary *results) {
                                                    [self parseContact:results];
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        [[NSNotificationCenter defaultCenter] postNotificationName:DATA_PARSED object:nil];
                                                        
                                                    });
                                                    
                                                }];
 
}


/**
 * Parses contact data and populates the contact object
 * @param dictionary of JSON data
 * @return none
 */

-(void) parseContact :(NSDictionary *)d{
    
    NSDictionary *acct = [d objectForKey:@"Account"];
    if([acct objectForKey:@"Name"] != [NSNull null])
        self.accountName = [acct objectForKey:@"Name"];
    if([d objectForKey:@"Email"] != [NSNull null])
        self.email = [d objectForKey:@"Email"];
    if([d objectForKey:@"Phone"] != [NSNull null])
        self.phone = [d objectForKey:@"Phone"];
    if([d objectForKey:@"title"] != [NSNull null])
        self.title = [d objectForKey:@"Title"];
    if(!self.questionAnswers)
        self.questionAnswers = [[NSMutableArray alloc]init];
    else [self.questionAnswers removeAllObjects];
    
    for(SurveryQuestion *question in [Contact questions]) {
        SurveyQuestionAnswer *qa = [[SurveyQuestionAnswer alloc]init];
        if([d objectForKey:question.apiName] != [NSNull null])
            qa.response = [d objectForKey:question.apiName];
        qa.questionObj = question;
        [questionAnswers addObject:qa];

    }
    
}

/**
 * Searches through the questions to accumulate the api names
 * @param none
 * @return Array of apinames
 */

-(NSArray *) apiNames {
    
    NSMutableArray *array = [[NSMutableArray alloc]initWithCapacity:[questions count]];
    for(SurveryQuestion *q in [Contact questions]) {
        [array addObject:q.apiName];
    }
    return array;
}

@end
