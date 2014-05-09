//
//  PageViewController.h
//  DrupalCMS
//
//  Created by Emma Smith on 08/05/2014.
//  Copyright (c) 2014 mmu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Node.h"

@interface PageViewController : UIPageViewController <UIPageViewControllerDataSource>

@property Node *node;
@property (nonatomic, strong) NSArray *nodes;
@property NSUInteger pageIndex;

@end
