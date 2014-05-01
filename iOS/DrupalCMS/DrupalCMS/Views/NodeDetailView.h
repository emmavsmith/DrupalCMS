//
//  NodeDetailView.h
//  DrupalCMS
//
//  Created by Emma Smith on 01/05/2014.
//  Copyright (c) 2014 mmu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NodeDetailView : UIView

@property (weak, nonatomic) IBOutlet UILabel *nodeTitleLabel;
@property (weak, nonatomic) IBOutlet UITextView *nodeContentTextView;
@property (weak, nonatomic) IBOutlet UIImageView *nodeImageView;

@end
