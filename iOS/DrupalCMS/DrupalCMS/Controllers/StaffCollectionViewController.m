//
//  StaffCollectionViewController.m
//  DrupalCMS
//
//  Created by Emma Smith on 06/05/2014.
//  Copyright (c) 2014 mmu. All rights reserved.
//

#import "StaffCollectionViewController.h"
#import "NodeDataProvider.h"
#import "StaffCollectionViewCell.h"
#import "Node.h"
#import "ContentManager.h"
#import "AppNameContentManager.h"
#import "DetailViewController.h"

@interface StaffCollectionViewController ()

@property (nonatomic)  NSMutableArray *nodeObjects;
@property NSNumber *nodequeueID;

@end

@implementation StaffCollectionViewController

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
        
        self.nodequeueID = [NSNumber numberWithInteger: NODEQUEUE_STAFF];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Collection view data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.nodeObjects count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    StaffCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"StaffCollectionViewCell" forIndexPath:indexPath];
    
    Node *node = [self.nodeObjects objectAtIndex:indexPath.row];
    cell.staffNameLabel.text = node.title;
    //TODO: will this always be field_image_profile?
    cell.staffImage.image = [node.images objectForKey:@"field_image_profile"];
    return cell;
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
    self.nodeObjects = [NodeDataProvider nodesWithNodequeueId:self.nodequeueID];
    [self.collectionView reloadData];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ViewCollectionItemDetailSegue"]) {
        
        NSArray *indexPaths = [self.collectionView indexPathsForSelectedItems];
        DetailViewController *detailViewController = segue.destinationViewController;
        NSIndexPath *indexPath = [indexPaths objectAtIndex:0];
        detailViewController.node = [self.nodeObjects objectAtIndex:indexPath.row];
        [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
    }
}

@end
