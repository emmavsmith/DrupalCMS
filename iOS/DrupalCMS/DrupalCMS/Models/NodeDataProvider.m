//
//  nodeDataProvider.m
//  DrupalCMS
//
//  Created by Emma Smith on 22/04/2014.
//  Copyright (c) 2014 mmu. All rights reserved.
//

#import "NodeDataProvider.h"
#import "Node.h"

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

+(NSArray *)extractJSON:(NSNumber *)nodequeueid
{
    NSLog(@"Extracting JSON");
    
    NSString *path = [self getPathToJSONFile:nodequeueid];
    
    //NSLog(@"Extracting JSON with path = %@", path);
    
    NSString *myJSON = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    //TODO: handle error when there is no content
    NSArray *json = [NSJSONSerialization JSONObjectWithData:[myJSON dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    return json;
}

+(NSString *)getPathToJSONFile:(NSNumber *)nodequeueid
{
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *path = [NSString stringWithFormat:@"%@%@%@", [documentsDirectory stringByAppendingString:@"/content_nqid_"], nodequeueid, @"/"];
    path = [path stringByAppendingPathComponent:@"manifest"];
    path = [path stringByAppendingPathExtension:@"JSON"];
    return path;
}

@end
