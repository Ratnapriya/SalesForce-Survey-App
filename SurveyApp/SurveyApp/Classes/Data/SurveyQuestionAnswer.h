//
//  SurveyQuestionAnswer.h
//  test1
//
//  Created by Ratna priya Saripalli on 11/12/13.
//  Copyright (c) 2013 myCompany. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface SurveryQuestion : NSObject {
    
    NSString *question;
    NSString *apiName;

}
@property (nonatomic, strong)NSString *apiName;
@property (nonatomic, strong)NSString *question;

@end

@interface SurveyQuestionAnswer : NSObject {
    
    SurveryQuestion *question;
    NSString *response;
    BOOL isDirty;
}

@property (nonatomic, strong)SurveryQuestion *questionObj;
@property (nonatomic, strong)NSString *response;
@property (nonatomic, assign)BOOL isDirty;

@end
