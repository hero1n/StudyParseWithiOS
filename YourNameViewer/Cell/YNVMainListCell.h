//
//  YNVMainListCell.h
//  YourNameViewer
//
//  Created by 노재원 on 2017. 2. 27..
//  Copyright © 2017년 heroin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YNVMainListCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *commentLabel;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *postDateLabel;

@end
