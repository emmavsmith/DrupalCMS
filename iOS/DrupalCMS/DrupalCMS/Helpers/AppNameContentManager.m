//
//  AppNameContentManager.m
//  DrupalCMS
//
//  Created by Emma Smith on 30/04/2014.
//  Copyright (c) 2014 mmu. All rights reserved.
//

#import "AppNameContentManager.h"

NSInteger const NODEQUEUE_LOCATION = 1;
NSInteger const NODEQUEUE_TABLE = 2;
NSInteger const NODEQUEUE_STAFF = 3;
NSInteger const NODEQUEUE_PAGE_TABLE = 4;

@implementation AppNameContentManager {

    NSArray *nodequeueIDs;
}

-(id) init
{
    self = [super initWithURL: @"http://cmstest.digitallabsmmu.com/contentpackagerjson/"];
    if (self){
        
        nodequeueIDs = @[[NSNumber numberWithInteger: NODEQUEUE_TABLE], [NSNumber numberWithInteger: NODEQUEUE_LOCATION], [NSNumber numberWithInteger: NODEQUEUE_STAFF], [NSNumber numberWithInteger: NODEQUEUE_PAGE_TABLE]];
    }
    return self;
}

-(void) checkForExistingContent
{
    for (NSNumber *nodequeueID in nodequeueIDs) {
        
        [self checkExistingContentWithNodequeueID: nodequeueID];
    }
}

-(void) checkForUpdates
{
    for (NSNumber *nodequeueID in nodequeueIDs) {
        
        [self checkForUpdateWithNodequeueID: nodequeueID];
    }
}

@end
