//
//  nodeDataProvider.h
//  DrupalCMS
//
//  Created by Emma Smith on 22/04/2014.
//  Copyright (c) 2014 mmu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NodeDataProvider : NSObject

+(NSMutableArray *)nodesWithNodequeueId:(NSNumber *)nodequeueid;
+(NSMutableArray *)locationNodesWithNodequeueId:(NSNumber *)nodequeueid;

@end
