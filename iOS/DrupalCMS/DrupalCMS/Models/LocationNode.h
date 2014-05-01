//
//  LocationNode.h
//  DrupalCMS
//
//  Created by Emma Smith on 30/04/2014.
//  Copyright (c) 2014 mmu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface LocationNode : NSObject <MKAnnotation>

-(id)initWithDictionary:(NSDictionary *)dictionary;

@end
