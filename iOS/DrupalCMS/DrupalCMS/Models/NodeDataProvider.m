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

+(Node *)createNodeWithDictionary:(NSDictionary *)dictionary withNodequeueId:(NSNumber *) nodequeueid
{
    Node *node = [[Node alloc] init];
    node.title = dictionary[@"title"];
    node.content = dictionary[@"body"][@"und"][0][@"value"];
    node.images = [NodeDataProvider getNodeImagesWithDictionary:dictionary withNodequeueId:nodequeueid];
    return node;
}

+(NSDictionary *)getNodeImagesWithDictionary:(NSDictionary *)dictionary withNodequeueId:(NSNumber *) nodequeueid
{
    NSString *fieldImageName;
    UIImage *image;
    NSMutableDictionary *images = [[NSMutableDictionary alloc] init];
    
    for (id key in dictionary){
    
        if (([key length] >= 11) && [[key substringWithRange: NSMakeRange(0, 11)] isEqualToString:@"field_image"]) {

            //TODO: keeping this array check in here for now as this was crashing before sometimes as it switches between accessing a dictionary and accessing an array, depending on whether the field_image is empty
            if(![[dictionary objectForKey:key] isKindOfClass:[NSArray class]]) {
            
                fieldImageName = dictionary[key][@"und"][0][@"filename"];
                
                if (fieldImageName != nil) {
                
                    NSString *path = [[ContentManager contentPathForNodequeueId:nodequeueid] stringByAppendingPathComponent:fieldImageName];
                    image = [UIImage imageWithContentsOfFile:path];
                    
                    [images setObject:image forKey:key];
                }
            }
        }
    }
    return [NSDictionary dictionaryWithDictionary: images];
}

#pragma mark - Location Nodes

+(NSArray *)locationNodesWithNodequeueId:(NSNumber *)nodequeueid
{
    NSLog(@"Parsing JSON array for Locations for nodequeueid: %@", nodequeueid);
    NSMutableArray *nodesArray = [[NSMutableArray alloc] init];
    NSArray *nodesFromJSON = [self extractJSON:nodequeueid];
    
    for(NSDictionary *item in nodesFromJSON) {
        
        if ([item[@"type"] isEqualToString:@"location"]) {
            
            LocationNode *locationNode = [NodeDataProvider createLocationNodeWithDictionary:item withNodequeueId:nodequeueid];
            [nodesArray addObject:locationNode];
        }
    }
    return nodesArray;
}

+(LocationNode *)createLocationNodeWithDictionary:(NSDictionary *)dictionary withNodequeueId:(NSNumber *) nodequeueid
{
    LocationNode *locationNode = [[LocationNode alloc] init];
    locationNode.title = dictionary[@"title"];
    
    //TODO: keeping this array check in here for now as this was crashing before sometimes as it switches between accessing a dictionary and accessing an array, depending on whether the field_subtitle is empty
    if(![dictionary[@"field_subtitle"] isKindOfClass:[NSArray class]]) {
    
        locationNode.subtitle = dictionary[@"field_subtitle"][@"und"][0][@"value"];
    }
        
    locationNode.content = dictionary[@"body"][@"und"][0][@"value"];
    //TODO: do not need to check type as already done where this method is called from??
    if([dictionary[@"type"] isEqualToString:@"location"]) {
        NSString *latitude = dictionary[@"field_geo_coordinate"][@"und"][0][@"lat"];
        NSString *longitude = dictionary[@"field_geo_coordinate"][@"und"][0][@"lng"];
        locationNode.coordinate = CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]);
    }
    return locationNode;
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
