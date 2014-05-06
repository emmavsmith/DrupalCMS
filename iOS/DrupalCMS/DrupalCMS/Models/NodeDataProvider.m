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
        
        Node *node = [NodeDataProvider createNodeWithDictionary:item withNodequeueId:nodequeueid];
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

+(Node *)createNodeWithDictionary:(NSDictionary *)dictionary withNodequeueId:(NSNumber *) nodequeueid
{
    Node *node = [[Node alloc] init];
    node.title = dictionary[@"title"];
    node.content = dictionary[@"body"][@"und"][0][@"value"];
    
    //TODO: image to specific for general node
    
    //get filename of an image
    if(![[dictionary objectForKey:@"field_image"] isKindOfClass:[NSArray class]]){
        
        node.fieldImageName = dictionary[@"field_image"][@"und"][0][@"filename"];
        //NSLog(@"Contains image key");
            
    } else {
        node.fieldImageName = nil;
        //NSLog(@"no image key");
    }
    
    //retrieve the image using the filename
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
    NSLog(@"Extracting JSON");
    NSString *path = [[ContentManager contentPathForNodequeueId:nodequeueid] stringByAppendingPathComponent:@"manifest.json"];
    NSString *myJSON = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    //TODO: handle error when there is no content?
    NSArray *json = [NSJSONSerialization JSONObjectWithData:[myJSON dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    return json;
}

@end
