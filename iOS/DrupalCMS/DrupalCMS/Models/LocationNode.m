//
//  LocationNode.m
//  DrupalCMS
//
//  Created by Emma Smith on 30/04/2014.
//  Copyright (c) 2014 mmu. All rights reserved.
//

#import "LocationNode.h"

@interface LocationNode ()
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, assign) CLLocationCoordinate2D theCoordinate;
@end

@implementation LocationNode

-(id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    
    if (self) {
        self.name = dictionary[@"title"];
        self.body = dictionary[@"body"][@"und"][0][@"value"];
        
        if([dictionary[@"type"] isEqualToString:@"location"]) {
            NSString *latitude = dictionary[@"field_geo_coordinate"][@"und"][0][@"lat"];
            NSString *longitude = dictionary[@"field_geo_coordinate"][@"und"][0][@"lng"];
            self.theCoordinate = CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]);
        }
    }
    return self;
}

- (NSString *)title {
    return _name;
}

- (NSString *)subtitle {
    return _body;
}

- (CLLocationCoordinate2D)coordinate {
    return _theCoordinate;
}

-(NSString*)description {
    return [NSString stringWithFormat:@"Title:%@ Location:%f,%f", self.title, self.theCoordinate.longitude, self.theCoordinate.latitude ];
}

@end
