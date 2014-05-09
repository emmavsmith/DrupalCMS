//
//  PageDetailViewController.m
//  DrupalCMS
//
//  Created by Emma Smith on 08/05/2014.
//  Copyright (c) 2014 mmu. All rights reserved.
//

#import "PageDetailViewController.h"

@interface PageDetailViewController ()

@end

@implementation PageDetailViewController

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
    
    self.titleLabel.text = self.titleText;
    [self.webView loadHTMLString:self.contentText baseURL:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
