//
//  NodesTableViewController.m
//  DrupalCMS
//
//  Created by Emma Smith on 23/04/2014.
//  Copyright (c) 2014 mmu. All rights reserved.
//

#import "NodesTableViewController.h"
#import "NodeDataProvider.h"
#import "NodesTableViewCell.h"
#import "Node.h"
#import "ContentManager.h"
#import "AppNameContentManager.h"
#import "DetailViewController.h"

@interface NodesTableViewController ()

@property (nonatomic)  NSMutableArray *nodeObjects;
@property NSNumber *nodequeueID;

@end

@implementation NodesTableViewController

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
        
        self.nodequeueID = [NSNumber numberWithInteger: NODEQUEUE_TABLE];
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

-(void)viewWillAppear:(BOOL)animated{

    NSLog(@"View will appear in table view controller");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.nodeObjects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NodesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NodesTableViewCell"];
    
    Node *node = [self.nodeObjects objectAtIndex:indexPath.row];
    cell.nodeTitleLabel.text = node.title;
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
    [self.tableView reloadData];
}

#pragma mark - Navigation

 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
     if ([segue.identifier isEqualToString:@"ViewListItemDetailSegue"]) {
         
         DetailViewController *detailViewController = [segue destinationViewController];
         detailViewController.node = self.nodeObjects[[self.tableView indexPathForSelectedRow].row];
     }
 }

@end
