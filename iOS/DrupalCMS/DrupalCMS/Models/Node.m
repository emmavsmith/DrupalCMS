//
//  Node.m
//  DrupalCMS
//
//  Created by Emma Smith on 17/04/2014.
//  Copyright (c) 2014 mmu. All rights reserved.
//

#import "Node.h"

@implementation Node

-(id)initWithTitle:(NSString *)titleIn withContent:(NSString *)contentIn
{
    self = [super init];
    if (self) {
        _title = titleIn;
        _content = contentIn;
    }
    
    return self;
}

@end
