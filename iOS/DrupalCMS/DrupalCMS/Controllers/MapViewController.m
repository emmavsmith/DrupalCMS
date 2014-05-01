//
//  MapViewController.m
//  DrupalCMS
//
//  Created by Chris Wilson on 30/04/2014.
//  Copyright (c) 2014 mmu. All rights reserved.
//

#import "MapViewController.h"
#import "NodeDataProvider.h"
#import "AppNameContentManager.h"
#import "LocationNode.h"

#define METERS_PER_MILE 1609.344

@interface MapViewController ()

@property (nonatomic)  NSMutableArray *nodeObjects;
@property NSNumber *nodequeueID;

@end

@implementation MapViewController

/*
 * Lazy instantiation of nodeObjects
 */
- (NSMutableArray *)nodeObjects
{
    if(!_nodeObjects){
        _nodeObjects = [[NSMutableArray alloc] init];
    }
    return _nodeObjects;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        self.nodequeueID = [NSNumber numberWithInteger: NODEQUEUE_TEST_1];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadNodesForNodequeueId];
    
    //listen for when content has been updated
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateContent:)
                                                 name:ContentUpdateDidCompleteNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {

    // Initial location to centre in on
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = 53.47053821505213;
    zoomLocation.longitude= -2.2396445274353027;
    
    // create a half mile region around the centre point
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 0.5 * METERS_PER_MILE);
    
    // set the mapView to display the region
    [_mapView setRegion:viewRegion animated:YES];
}

#pragma mark - Nodequeues nodes

/*
 * Retrieves information passed over from observer when content has been updated
 */
-(void)updateContent:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    
    if ([[userInfo objectForKey:@"nodequeueID"]  compare:self.nodequeueID] == NSOrderedSame){
        
        [self loadNodesForNodequeueId];
    }
}

/*
 * Retrieves an array of node objects and reloads the tableView so it can be populated with the retrieved nodes
 */
-(void)loadNodesForNodequeueId
{
    self.nodeObjects = [NodeDataProvider locationNodesWithNodequeueId:self.nodequeueID];

    // clear existing annotations
    NSMutableArray *annotationsToRemove = [[NSMutableArray alloc] initWithArray: _mapView.annotations];
    //Remove the object userlocation from the array of items to remove
    [annotationsToRemove removeObject: _mapView.userLocation];
    //Remove all annotations in the array from the mapView
    [_mapView removeAnnotations: annotationsToRemove];
    
    // Update mapPoints
    for(LocationNode *annotation in self.nodeObjects) {
        [self.mapView addAnnotation:annotation];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
