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

-(id)init
{
    self = [super init];
    if(self){
        self.nodesArray = [[NSMutableArray alloc] init];
    }
    return self;
}


-(void)retrieveJSONFile:(NSNumber *)nodequeueid
{
    NSLog(@"Retrieving JSON file");
    
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *path = [NSString stringWithFormat:@"%@%@%@", [documentsDirectory stringByAppendingString:@"/content_nqid_"], nodequeueid, @"/"];
    path = [path stringByAppendingPathComponent:@"manifest"];
    path = [path stringByAppendingPathExtension:@"JSON"];
    
    NSString *myJSON = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray *json = [NSJSONSerialization JSONObjectWithData:[myJSON dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    
    [self parseNodesFromJSON: json toArray: _nodesArray];
}


-(void)parseNodesFromJSON:(NSArray *)nodesFromJSON toArray:(NSMutableArray *)nodesArray
{
    NSLog(@"Parsing JSON array");
    
    for(NSDictionary *item in nodesFromJSON) {
    
        Node *node = [[Node alloc] initWithDictionary:item];
        [nodesArray addObject:node];
    }
    NSLog(@"nodesArray: %@", nodesArray);
}

@end
