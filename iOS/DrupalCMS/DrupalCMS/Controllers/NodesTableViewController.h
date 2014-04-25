//
//  NodesTableViewController.h
//  DrupalCMS
//
//  Created by Emma Smith on 23/04/2014.
//  Copyright (c) 2014 mmu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NodesTableViewController : UITableViewController 

-(void)retrieveAndReloadNodes:(NSNumber *)nodequeueID;

@end
