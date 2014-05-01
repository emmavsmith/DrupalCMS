//
//  nodeDataProvider.m
//  DrupalCMS
//
//  Created by Emma Smith on 22/04/2014.
//  Copyright (c) 2014 mmu. All rights reserved.
//

#import "NodeDataProvider.h"
#import "ContentManager.h"
#import "Node.h"
#import "LocationNode.h"

@implementation NodeDataProvider

+(NSArray *)getNodesWithNodequeueId:(NSNumber *)nodequeueid
{
    NSLog(@"Parsing JSON array");
    NSMutableArray *nodesArray = [[NSMutableArray alloc] init];
    NSArray *nodesFromJSON = [self extractJSON:nodequeueid];
    
    for(NSDictionary *item in nodesFromJSON) {
        
        Node *node = [[Node alloc] initWithDictionary:item];
        [nodesArray addObject:node];
    }
    return nodesArray;
}

+(NSArray *)getLocationNodesWithNodequeueId:(NSNumber *)nodequeueid
{
    NSLog(@"Parsing JSON array for Locations");
    NSMutableArray *nodesArray = [[NSMutableArray alloc] init];
    NSArray *nodesFromJSON = [self extractJSON:nodequeueid];
    
    for(NSDictionary *item in nodesFromJSON) {
        
        if ([item[@"type"] isEqualToString:@"location"]) {
            LocationNode *node = [[LocationNode alloc] initWithDictionary:item];
            [nodesArray addObject:node];
        }
    }
    return nodesArray;
}

+(NSArray *)extractJSON:(NSNumber *)nodequeueid
{
    NSLog(@"Extracting JSON");
    NSString *path = [[ContentManager contentPathForNodequeueId:nodequeueid] stringByAppendingPathComponent:@"manifest.json"];
    NSString *myJSON = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    //TODO: handle error when there is no content?
    NSArray *json = [NSJSONSerialization JSONObjectWithData:[myJSON dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    return json;
}

@end
