// Copyright (c) Microsoft. All rights reserved.
// Licensed under the MIT license.
//
// Microsoft Cognitive Services (formerly Project Oxford): https://www.microsoft.com/cognitive-services
//
// Microsoft Cognitive Services (formerly Project Oxford) GitHub:
// https://github.com/Microsoft/Cognitive-Face-iOS
//
// Copyright (c) Microsoft Corporation
// All rights reserved.
//
// MIT License:
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED ""AS IS"", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <XCTest/XCTest.h>
#import "MPOFaceSDK.h"
#import "MPOTestConstants.h"
#define kLargeFaceListName @"testlargefacelist1"

@interface LargeFaceListTestCase : XCTestCase

@end

@implementation LargeFaceListTestCase

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    
    __block BOOL finished = NO;
    
    MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithEndpointAndSubscriptionKey:kOxfordApiEndPoint key:kOxfordApiKey];
    
    [client deleteLargeFaceList:kLargeFaceListName name:@"chrisfacelistname" userData:@"chrisfacelistuserdata" completionBlock:^(NSError *error) {
        
        if (error) {
            NSLog(@"error in teardown");
        }
        else {
            finished = YES;
        }
        
    }];
    
    while (!finished) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    [super tearDown];
}

- (void)testCreateCreateFaceList {
    XCTestExpectation *expectation = [self expectationWithDescription:@"asynchronous request"];
    
    MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithEndpointAndSubscriptionKey:kOxfordApiEndPoint key:kOxfordApiKey];
    
    [client createLargeFaceList:kLargeFaceListName name:@"chrisfacelistname" userData:@"chrisfacelistuserdata" completionBlock:^(NSError *error) {
        
        if (error) {
            XCTFail();
        }
        else {
            [self addFirstFaceToLargeFaceList:expectation];
        }
        
    }];
    
    [self waitForExpectationsWithTimeout:60.0 handler:nil];
    
}

- (void)addFirstFaceToLargeFaceList:(XCTestExpectation *)expectation {
    
    MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithEndpointAndSubscriptionKey:kOxfordApiEndPoint key:kOxfordApiKey];
    
    [client addFaceInLargeFaceList:kLargeFaceListName data:UIImageJPEGRepresentation([UIImage imageNamed:kChrisImageName1], 1.0) userData:@"chrisfacelistuserdata1" faceRectangle:nil completionBlock:^(MPOAddPersistedFaceResult *addPersistedFaceResult, NSError *error) {
        
        if (error) {
            XCTFail();
        }
        else {
            [self addSecondFaceToFaceList:expectation];
        }
        
    }];
    
}

- (void)addSecondFaceToFaceList:(XCTestExpectation *)expectation {
    
    MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithEndpointAndSubscriptionKey:kOxfordApiEndPoint key:kOxfordApiKey];
    
    [client addFaceInLargeFaceList:kLargeFaceListName data:UIImageJPEGRepresentation([UIImage imageNamed:kChrisImageName2], 1.0) userData:@"chrisfacelistuserdata2" faceRectangle:nil completionBlock:^(MPOAddPersistedFaceResult *addPersistedFaceResult, NSError *error) {
        
        if (error) {
            XCTFail();
        }
        else {
            [self listLargeFaceLists:expectation];
        }
        
    }];
    
}


- (void)listLargeFaceLists:(XCTestExpectation *)expectation {
    
    MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithEndpointAndSubscriptionKey:kOxfordApiEndPoint key:kOxfordApiKey];
    
    [client listLargeFaceListsWithCompletion:^(NSArray<MPOLargeFaceList *> *collection, NSError *error) {
        
        if (error) {
            XCTFail();
        }
        else {
            XCTAssertEqual(collection.count, 34);
            [self getLargeFaceList:expectation];
        }
        
    }];
    
}


- (void)getLargeFaceList:(XCTestExpectation *)expectation {
    
    MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithEndpointAndSubscriptionKey:kOxfordApiEndPoint key:kOxfordApiKey];
    
    [client getLargeFaceList:kLargeFaceListName completionBlock:^(MPOLargeFaceList *getLargeFaceList, NSError *error) {
        
        if (error) {
            XCTFail();
        }
        else {
            XCTAssertEqualObjects(getLargeFaceList.largeFaceListId, kLargeFaceListName);
            [self trainLargeFaceList:expectation];
        }
        
    }];
    
}

- (void)trainLargeFaceList:(XCTestExpectation *)expectation {
    
    MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithEndpointAndSubscriptionKey:kOxfordApiEndPoint key:kOxfordApiKey];
    
    [client trainLargeFaceList:kLargeFaceListName completionBlock:^( NSError *error) {
        
        if (error) {
            XCTFail();
        }
        else {
            [self getTrainingSTatus:expectation];
        }
        
    }];
    
}

-(void)getTrainingSTatus:(XCTestExpectation *)expectation {
    MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithEndpointAndSubscriptionKey:kOxfordApiEndPoint key:kOxfordApiKey];
    
    [client getLargeFaceListTrainingStatus:kLargeFaceListName completionBlock:^(MPOTrainingStatus *trainingStatus, NSError *error) {
        
        if (error) {
            XCTFail();
        }
        else {
            XCTAssertEqualObjects(trainingStatus.status, @"succeeded");
            [expectation fulfill];
        }
        
    }];
    
}

@end
