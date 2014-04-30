//
//  AppNameContentManager.m
//  DrupalCMS
//
//  Created by Emma Smith on 30/04/2014.
//  Copyright (c) 2014 mmu. All rights reserved.
//

#import "AppNameContentManager.h"

@implementation AppNameContentManager

-(id) init
{
    self = [super initWithURL: @"http://cmstest.digitallabsmmu.com/contentpackagerjson/"];
    if (self){
    }
    return self;
}

//TODO: create instance array and populate with defines in init
//TODO: check for existing content method to loop through array and call appropriate content manager method
//TODO: check for updates method to loop through array and call appropriate content manager method

@end
