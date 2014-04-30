//
//  AppNameContentManager.h
//  DrupalCMS
//
//  Created by Emma Smith on 30/04/2014.
//  Copyright (c) 2014 mmu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContentManager.h"

extern NSInteger const NODEQUEUE_TEST_1;
extern NSInteger const NODEQUEUE_GLOSSARY;

@interface AppNameContentManager : ContentManager

-(void) checkForExistingContent;
-(void) checkForUpdates;

@end
