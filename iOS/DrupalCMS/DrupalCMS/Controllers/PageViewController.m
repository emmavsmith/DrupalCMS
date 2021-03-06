//
//  PageViewController.m
//  DrupalCMS
//
//  Created by Emma Smith on 08/05/2014.
//  Copyright (c) 2014 mmu. All rights reserved.
//

#import "PageViewController.h"
#import "PageDetailViewController.h"
#import "NodeDataProvider.h"
#import "AppNameContentManager.h"
#import "Node.h"

@interface PageViewController ()

@end

@implementation PageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.nodes = [NodeDataProvider nodesWithNodequeueId:[NSNumber numberWithInteger: (NODEQUEUE_PAGE_TABLE)]];
    
    // load initial page
    PageDetailViewController *startingViewController = [self viewControllerAtIndex:self.pageIndex];
    NSArray *viewControllers = @[startingViewController];
    [self setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    self.dataSource = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeBottom;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (PageDetailViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.nodes count] == 0) || (index >= [self.nodes count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    PageDetailViewController *pageDetailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SB_PageDetailViewController"];
    pageDetailViewController.node = [self.nodes objectAtIndex:index];
    pageDetailViewController.pageIndex = index;
    return pageDetailViewController;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageDetailViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageDetailViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.nodes count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

@end
