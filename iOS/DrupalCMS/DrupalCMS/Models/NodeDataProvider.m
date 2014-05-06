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
    NSLog(@"Parsing JSON array for nodequeueid: %@", nodequeueid);
    NSMutableArray *nodesArray = [[NSMutableArray alloc] init];
    NSArray *nodesFromJSON = [self extractJSON:nodequeueid];
    
    for(NSDictionary *item in nodesFromJSON) {
        
        Node *node = [NodeDataProvider createNodeWithDictionary:item withNodequeueId:nodequeueid];
        [nodesArray addObject:node];
    }
    return nodesArray;
}

+(NSArray *)locationNodesWithNodequeueId:(NSNumber *)nodequeueid
{
    NSLog(@"Parsing JSON array for Locations for nodequeueid: %@", nodequeueid);
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

+(Node *)createNodeWithDictionary:(NSDictionary *)dictionary withNodequeueId:(NSNumber *) nodequeueid
{
    Node *node = [[Node alloc] init];
    node.title = dictionary[@"title"];
    node.content = dictionary[@"body"][@"und"][0][@"value"];
    
    //TODO: image to specific for general node
    
    //TODO: keeping this array check in here for now as this was crashing before sometimes as it switches between accessing a dictionary and accessing an array, depending on whether the field_image is empty
    if(![[dictionary objectForKey:@"field_image"] isKindOfClass:[NSArray class]]){
        
        node.fieldImageName = dictionary[@"field_image"][@"und"][0][@"filename"];
        //NSLog(@"Contains image key %@", node.fieldImageName);
            
    } else {
        node.fieldImageName = nil;
        //NSLog(@"no image key");
    }

    if(node.fieldImageName != nil){

        NSString *path = [[ContentManager contentPathForNodequeueId:nodequeueid] stringByAppendingPathComponent:node.fieldImageName];
        node.image = [UIImage imageWithContentsOfFile:path];
        
    } else {
        node.image = nil;
    }
    return node;
}

#pragma mark - JSON

+(NSArray *)extractJSON:(NSNumber *)nodequeueid
{
    NSLog(@"Extracting JSON for nodequeueid: %@", nodequeueid);
    NSString *path = [[ContentManager contentPathForNodequeueId:nodequeueid] stringByAppendingPathComponent:@"manifest.json"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //check if there is a json file before trying to extract the json
    if([fileManager fileExistsAtPath:path]){
        
        NSString *myJSON = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        NSArray *json = [NSJSONSerialization JSONObjectWithData:[myJSON dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        return json;
    }
    return nil;
}

@end
