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

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end
