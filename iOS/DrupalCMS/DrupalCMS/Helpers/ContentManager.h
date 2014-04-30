//
//  DownloadZipController.h
//  DrupalCMS
//
//  Created by Emma Smith on 24/04/2014.
//  Copyright (c) 2014 mmu. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const ContentUpdateDidCompleteNotification;

@interface ContentManager : NSObject

-(id) initWithURL:(NSString *) drupalDownloadURLIn;
-(void)checkExistingContentWithNodequeueID:(NSNumber *)nodequeueID;
-(void)checkForUpdateWithNodequeueID:(NSNumber *)nodequeueID;
+(NSString *)contentPathForNodequeueId:(NSNumber *)nodequeueID;

@end
