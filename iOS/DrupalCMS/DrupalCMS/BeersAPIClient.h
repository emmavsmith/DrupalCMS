//
//  BeersAPIClient.h
//  DrupalCMS
//
//  Created by Emma Smith on 15/04/2014.
//  Copyright (c) 2014 mmu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface BeersAPIClient : AFHTTPClient

+ (id)sharedInstance;

@end
