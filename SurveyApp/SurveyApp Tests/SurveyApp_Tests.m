//
//  SurveyApp_Tests.m
//  SurveyApp Tests
//
//  Created by Ratna priya Saripalli on 11/15/13.
//  Copyright (c) 2013 worlddomination. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "Contact.h"

@interface SurveyApp_Tests : SenTestCase{
    
    Contact *contact;
}


@end

@implementation SurveyApp_Tests

- (void)setUp
{
    [super setUp];
    contact = [[Contact alloc] init];

    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)test_Contact_ParseQuestions {
    
    [Contact parseQuestionData:[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"test",@"name",@"test survey question",@"inlineHelpText",nil], nil]];
    STAssertNotNil([Contact questions], @"Parse questions failed");
}

- (void)test_Contact_ParseContact {
    
    [contact parseContact:[NSDictionary dictionaryWithObjectsAndKeys:[NSDictionary dictionaryWithObjectsAndKeys:@"test account",@"Name", nil],@"Account",@"test email",@"Email",@"test ph",@"Phone",@"test title",@"Title",nil]];
    STAssertNotNil(contact.accountName, @"Parse contact name failed");
    STAssertNotNil(contact.email, @"Parse contact email failed");
    STAssertNotNil(contact.phone, @"Parse contact phone failed");
    STAssertNotNil(contact.title, @"Parse contact title failed");

}


- (void)test_Contact_FetchQuestions {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    
    [Contact fetchQuestions];
    __block __weak id observer = [[NSNotificationCenter defaultCenter] addObserverForName:QUESTIONS_DATA_PARSED
                                                                                   object:nil
                                                                                    queue:[NSOperationQueue mainQueue]
                                                                               usingBlock:^(NSNotification *notification) {
                                                                                                                                                                  [[NSNotificationCenter defaultCenter] removeObserver:observer name:QUESTIONS_DATA_PARSED object:nil];
                                                                                       STAssertNotNil([Contact questions], @"Questions not parsed");
                                                                                       dispatch_semaphore_signal(semaphore);

                                                                               }];
    

    
    
    // Run loop
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
}




- (void)test_Contact_FetchContact {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    contact.Id = @"003i000000QVJYtAAP";
    [contact fetchContact];

    __block __weak id observer = [[NSNotificationCenter defaultCenter] addObserverForName:DATA_PARSED
                                                                                   object:nil
                                                                                    queue:[NSOperationQueue mainQueue]
                                                                               usingBlock:^(NSNotification *notification) {
                                                                                   [[NSNotificationCenter defaultCenter] removeObserver:observer name:DATA_PARSED object:nil];
                                                                                   STAssertNotNil(contact.accountName, @"Parse contact name failed");
                                                                                   STAssertNotNil(contact.email, @"Parse contact email failed");
                                                                                   STAssertNotNil(contact.phone, @"Parse contact phone failed");
                                                                                   STAssertNotNil(contact.title, @"Parse contact title failed");
                                                                                   dispatch_semaphore_signal(semaphore);
                                                                                   
                                                                               }];
    
    
    
    
    // Run loop
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];

    
}

- (void)test_Contact_UpadateContactResponse {
    [self test_Contact_FetchQuestions];
    [self test_Contact_FetchContact];
    for(SurveyQuestionAnswer *qa in contact.questionAnswers) {
        qa.response = @"This is a test for update response";
    }
        
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    contact.Id = @"003i000000QVJYtAAP";
    [contact fetchContact];
    
    __block __weak id observer = [[NSNotificationCenter defaultCenter] addObserverForName:SURVEYQUESTIONS_RESPONSE_SAVED
                                                                                   object:nil
                                                                                    queue:[NSOperationQueue mainQueue]
                                                                               usingBlock:^(NSNotification *notification) {
                                                                                   [[NSNotificationCenter defaultCenter] removeObserver:observer name:SURVEYQUESTIONS_RESPONSE_SAVED object:nil];
                                                                                   dispatch_semaphore_signal(semaphore);
                                                                                   
                                                                               }];
    
    
    
    
    // Run loop
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    
    

}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    STFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}


@end
