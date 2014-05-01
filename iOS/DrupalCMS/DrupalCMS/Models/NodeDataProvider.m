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

#pragma mark - Nodes

+(NSArray *)nodesWithNodequeueId:(NSNumber *)nodequeueid
{
    NSLog(@"Parsing JSON array");
    NSMutableArray *nodesArray = [[NSMutableArray alloc] init];
    NSArray *nodesFromJSON = [self extractJSON:nodequeueid];
    
    for(NSDictionary *item in nodesFromJSON) {
        
        Node *node = [NodeDataProvider createNode:item];
        [nodesArray addObject:node];
    }
    return nodesArray;
}

+(NSArray *)locationNodesWithNodequeueId:(NSNumber *)nodequeueid
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

+(Node *)createNode:(NSDictionary *)dictionary
{
    Node *node = [[Node alloc] init];
    node.title = dictionary[@"title"];
    node.content = dictionary[@"body"][@"und"][0][@"value"];
    
    //NSLog(@"%@", dictionary);
    
    //TODO: image to specific for general node
    if(![[dictionary objectForKey:@"field_image"] isKindOfClass:[NSArray class]]){
            
        //NSLog(@"Contains image key");
        node.fieldImagePath = dictionary[@"field_image"][@"und"][0][@"filename"];
            
    } else {
        node.fieldImagePath = nil;
        //NSLog(@"no image key");
    }
    
    //NSLog(@"field_image path = %@", node.fieldImagePath );
    
    //TODO: extract images from documents directory and save to node.image
    node.image = nil;
    return node;
}

#pragma mark - JSON

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
