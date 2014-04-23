//
//  NodesTableViewCell.m
//  DrupalCMS
//
//  Created by Emma Smith on 23/04/2014.
//  Copyright (c) 2014 mmu. All rights reserved.
//

#import "NodesTableViewCell.h"

@implementation NodesTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
