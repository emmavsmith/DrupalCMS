//
//  Node.m
//  DrupalCMS
//
//  Created by Emma Smith on 17/04/2014.
//  Copyright (c) 2014 mmu. All rights reserved.
//

#import "Node.h"

@implementation Node

-(id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    
    if (self) {
        self.title = dictionary[@"title"];
        //TODO type will be an object of it's own rather than a property, i.e. will create a node of type glossary etc.
        self.type = [NSString stringWithFormat:@"%@", dictionary[@"type"]];
        self.content = dictionary[@"body"][@"und"][0][@"value"];
        
        NSLog(@"Creating node with; title: %@, type: %@, content: %@", self.title, self.type, self.content);
        
        //TODO images??
    }
    return self;
}

@end
