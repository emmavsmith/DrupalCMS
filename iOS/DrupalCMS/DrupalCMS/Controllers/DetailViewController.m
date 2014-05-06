//
//  DetailViewController.m
//  DrupalCMS
//
//  Created by Emma Smith on 01/05/2014.
//  Copyright (c) 2014 mmu. All rights reserved.
//

#import "DetailViewController.h"
#import "NodeDetailView.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

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
    
    [self populateNodeDetailView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) populateNodeDetailView
{
    self.nodeDetailView.nodeTitleLabel.text = self.node.title;
    self.nodeDetailView.nodeContentTextView.text = self.node.content;
    self.nodeDetailView.nodeImageView.image = self.node.image;
}

@end
