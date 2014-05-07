//
//  DetailViewController.h
//  DrupalCMS
//
//  Created by Emma Smith on 01/05/2014.
//  Copyright (c) 2014 mmu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Node.h"
#import "DetailView.h"

@interface DetailViewController : UIViewController

@property Node *node;
@property IBOutlet DetailView *nodeDetailView;

@end
