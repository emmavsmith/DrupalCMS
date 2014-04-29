//
//  DownloadZipController.h
//  DrupalCMS
//
//  Created by Emma Smith on 24/04/2014.
//  Copyright (c) 2014 mmu. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const ContentUpdateDidComplete;

@interface ContentManager : NSObject

-(void)checkExistingContent;
-(void)checkForUpdate;
+(NSString *)contentPathForNodequeueId:(NSNumber *)nodequeueID;

@end
