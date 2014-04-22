//
//  Node.h
//  DrupalCMS
//
//  Created by Emma Smith on 17/04/2014.
//  Copyright (c) 2014 mmu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Node : NSObject

@property NSString *title;
@property NSString *type;
@property NSString *content;


-(id)initWithDictionary:(NSDictionary *)dictionary;

@end
