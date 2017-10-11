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
#import "MPOTestConstants.h"
#import "MPOFaceSDK.h"
#import "MPOTestHelpers.h"
#define kLargePersonGroup @"testlargepersongroupid"
@interface LargePersonGroupTestCase : XCTestCase

@end

@implementation LargePersonGroupTestCase

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    [MPOTestHelpers clearAllLargePersonGroups];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testLargePersonGroup {
    
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"asynchronous request"];
    
    MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithEndpointAndSubscriptionKey:kOxfordApiEndPoint key:kOxfordApiKey];
    
    [client createLargePersonGroup:kLargePersonGroup name:@"test_persongroup_name" userData:@"test_persongroup_userdata" completionBlock:^(NSError *error) {
        
        if (error) {
            XCTFail("error creating test person group");
        }
        else {
            [self getLargePersonGroup:expectation];
        }
        
    }];
    
    [self waitForExpectationsWithTimeout:100.0 handler:nil];
    
}

- (void)getLargePersonGroup:(XCTestExpectation *)expectation {
    
    MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithEndpointAndSubscriptionKey:kOxfordApiEndPoint key:kOxfordApiKey];
    
    [client getLargePersonGroup:kLargePersonGroup completionBlock:^(MPOLargePersonGroup *largePersonGroup, NSError *error) {
        
        if (error) {
            XCTFail("error");
        }
        else {
            XCTAssertEqualObjects(largePersonGroup.largePersonGroupId, kLargePersonGroup);
        }
        [self updateLargePersonGroup:expectation];
        
    }];
    
}

- (void)updateLargePersonGroup:(XCTestExpectation *)expectation {
    MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithEndpointAndSubscriptionKey:kOxfordApiEndPoint key:kOxfordApiKey];
    
    [client updateLargePersonGroup:kLargePersonGroup name:@"test_persongroup_name_update" userData:@"test_persongroup_userdata_update" completionBlock:^(NSError *error) {
        
        if (error) {
            XCTFail("error");
        }
        [self checkIfUpdateWorked:expectation];
        
    }];
    
}

- (void)checkIfUpdateWorked:(XCTestExpectation *)expectation {
    
    MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithEndpointAndSubscriptionKey:kOxfordApiEndPoint key:kOxfordApiKey];
    
    [client getLargePersonGroup:kLargePersonGroup completionBlock:^(MPOLargePersonGroup *largePersonGroup, NSError *error) {
    
        if (error) {
            XCTFail("error");
        }
        else {
            XCTAssertEqualObjects(largePersonGroup.name, @"test_persongroup_name_update");
            XCTAssertEqualObjects(largePersonGroup.userData, @"test_persongroup_userdata_update");
        }
        [self deleteLargePersonGroup:expectation];
        
    }];
    
}

- (void)deleteLargePersonGroup:(XCTestExpectation *)expectation {
    
    MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithEndpointAndSubscriptionKey:kOxfordApiEndPoint key:kOxfordApiKey];
    
    [client deleteLargePersonGroup:kLargePersonGroup completionBlock:^(NSError *error) {
        
        if (error) {
            XCTFail("error");
        }
        [expectation fulfill];
        
    }];
    
}

@end
