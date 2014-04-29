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

@interface NodesTableViewController ()

@property (nonatomic)  NSMutableArray *nodeObjects;

#define ZIP_FILE_FINISHED_DOWNLOAD @"ContentZipFileFinishedDownload"

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

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
        self.nodeObjects = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //TODO: change nodequeueid
    self.nodeObjects = [NodeDataProvider getNodesWithNodequeueId:@1];
    
    //listen for when a zip file has been downloaded and unzipped
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(downloadZipComplete:)
                                                 name:ZIP_FILE_FINISHED_DOWNLOAD
                                               object:nil];
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
 * Called when a zip folder has been downloaded and unzipped where it retrieves a nodequeueID
 */
-(void)downloadZipComplete:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSNumber *nodequeueID = [userInfo objectForKey:@"nodequeueID"];
    [self getAndReloadNodes:nodequeueID];
}

/*
 * Retrieves an array of node objects and reloads the tableView so it can be populated with the retrieved nodes
 */
-(void)getAndReloadNodes:(NSNumber *)nodequeueID
{
    self.nodeObjects = [NodeDataProvider getNodesWithNodequeueId:nodequeueID];
    [self.tableView reloadData];
}

@end
