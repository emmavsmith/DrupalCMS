//
//  AppNameContentManager.h
//  DrupalCMS
//
//  Created by Emma Smith on 30/04/2014.
//  Copyright (c) 2014 mmu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContentManager.h"

extern NSInteger const NODEQUEUE_LOCATION;
extern NSInteger const NODEQUEUE_TABLE;
extern NSInteger const NODEQUEUE_STAFF;
extern NSInteger const NODEQUEUE_PAGE_TABLE;

@interface AppNameContentManager : ContentManager

-(void) checkForExistingContent;
-(void) checkForUpdates;

@end
