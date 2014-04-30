//
//  AppNameContentManager.m
//  DrupalCMS
//
//  Created by Emma Smith on 30/04/2014.
//  Copyright (c) 2014 mmu. All rights reserved.
//

#import "AppNameContentManager.h"

NSInteger const NODEQUEUE_TEST_1 = 1;
NSInteger const NODEQUEUE_GLOSSARY = 2;

@implementation AppNameContentManager {

    NSArray *nodequeueIDs;
}

-(id) init
{
    self = [super initWithURL: @"http://cmstest.digitallabsmmu.com/contentpackagerjson/"];
    if (self){
        
        nodequeueIDs = @[[NSNumber numberWithInteger: NODEQUEUE_TEST_1], [NSNumber numberWithInteger: NODEQUEUE_GLOSSARY]];
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
