//
//  YNVDetailViewController.m
//  YourNameViewer
//
//  Created by 노재원 on 2017. 2. 27..
//  Copyright © 2017년 heroin. All rights reserved.
//

#import "YNVDetailViewController.h"

// Libraries
#import "TFHpple.h"

@interface YNVImageTextAttachment : NSTextAttachment

@property (strong, nonatomic) NSString *imageURLString;

@end

@implementation YNVImageTextAttachment

@end

@interface YNVDetailViewController ()

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation YNVDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(refresh)
                  forControlEvents:UIControlEventValueChanged];
    [self.textView addSubview:self.refreshControl];
    self.textView.scrollEnabled = YES;
    
    [self getPost];
}

- (void)refresh {
    self.textView.text = @"";
    
    [self getPost];
    [self.refreshControl endRefreshing];
}

- (void)getPost {
    [self.view makeToastActivity:CSToastPositionCenter];
    NSMutableAttributedString *contentString = [[NSMutableAttributedString alloc]
                                                initWithString:[self.listData.title stringByAppendingString:@"\n"]
                                                attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:15.0f]}
                                                ];
    
    [contentString appendAttributedString:[[NSMutableAttributedString alloc]
                                           initWithString:[self.listData.userName stringByAppendingString:@"    "]
                                           attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14.0f],
                                                        NSForegroundColorAttributeName : [UIColor lightGrayColor]}
                                           ]];
    
    [contentString appendAttributedString:[[NSMutableAttributedString alloc]
                                           initWithString:self.listData.postDateString
                                           attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14.0f],
                                                        NSForegroundColorAttributeName : [UIColor lightGrayColor]}
                                           ]];
    
    [contentString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n\n"]];
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
        NSString *XPathQuery = @"//*[@id='dgn_content_de']/div[2]/div[1]/div";
        //*[@id="dgn_content_de"]/div[2]/div[1]/div/table/tbody/tr
        NSString *postURLString = [GALLERY_END_POINT stringByAppendingString:self.listData.postLink];
        NSURL *postURL = [NSURL URLWithString:postURLString];
        NSData *postHTMLData = [NSData dataWithContentsOfURL:postURL];
        
        TFHpple *postParser = [TFHpple hppleWithHTMLData:postHTMLData];
        NSArray<TFHppleElement *> *parsedArray = [postParser searchWithXPathQuery:XPathQuery];
        
        TFHppleElement *element = parsedArray.firstObject;
        NSLog(@"<<<<<< %@ <> %@ <> %@ <> %@ >>>>>>>", element.text, element.tagName, element.attributes, element.children);
        
        if ([element firstChildWithTagName:@"a"] != nil) {
            NSString *srcString = [[element firstChildWithTagName:@"a"] firstChildWithTagName:@"img"].attributes[@"src"];
            
            if (srcString.length > 0) {
                [contentString appendAttributedString:[NSMutableAttributedString attributedStringWithAttachment:[self textAttachmentWithImageURL:srcString]]];
            }
        } else if ([element firstChildWithTagName:@"img"] != nil) {
            NSString *srcString = [element firstChildWithTagName:@"img"].attributes[@"src"];
            
            if (srcString.length > 0) {
                [contentString appendAttributedString:[NSMutableAttributedString attributedStringWithAttachment:[self textAttachmentWithImageURL:srcString]]];
            }
        }
        
        TFHppleElement *tdElement = [[[parsedArray.firstObject firstChildWithTagName:@"table"] firstChildWithTagName:@"tr"] firstChildWithTagName:@"td"];
        NSLog(@"<<<<<< %@ <> %@ <> %@ <> %@ >>>>>>>", tdElement.text, tdElement.tagName, tdElement.attributes, tdElement.children);
        
        for (TFHppleElement *element in tdElement.children) {
            NSLog(@"<<<<<< %@ <> %@ <> %@ <> %@ >>>>>>>", element.text, element.tagName, element.attributes, element.children);
            
            if ([element isTextNode]) {
                if (element.text.length > 0) {
                    [contentString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:element.text]];
                } else if (element.content.length > 0) {
                    [contentString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:element.content]];
                }
            } else if (element.text.length > 0) {
                for (TFHppleElement *childElement in element.children) {
                    if ([childElement.tagName isEqualToString:@"br"]) {
                        [contentString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@" \n"]];
                    }
                    if ([childElement.tagName isEqualToString:@"text"]) {
                        [contentString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:childElement.content]];
                    }
                }
            } else if ([element.tagName isEqualToString:@"br"]) {
                [contentString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@" \n"]];
            } else if ([element.tagName isEqualToString:@"text"]) {
                [contentString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:element.content]];
            } else if ([element.tagName isEqualToString:@"div"] ||
                       [((TFHppleElement *)element.children.firstObject).tagName isEqualToString:@"img"] ||
                       [element firstChildWithTagName:@"img"]) {
                NSString *srcString = ((TFHppleElement *)element.children.firstObject).attributes[@"src"];
                
                if (srcString.length > 0) {
                    [contentString appendAttributedString:[NSMutableAttributedString attributedStringWithAttachment:[self textAttachmentWithImageURL:srcString]]];
                }
            } else if ([element.tagName isEqualToString:@"img"]) {
                NSString *srcString = element.attributes[@"src"];
                
                if (srcString.length > 0) {
                    [contentString appendAttributedString:[NSMutableAttributedString attributedStringWithAttachment:[self textAttachmentWithImageURL:srcString]]];
                }
            } else if (element.hasChildren) {
                for (TFHppleElement *child in element.children) {
                    if (child.content != nil) {
                        [contentString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:child.content]];
                    }
                    if ([child.children count]!= 0) {
                        for (TFHppleElement *grandchild in child.children) {
                            if (grandchild.content != nil) {
                                [contentString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:grandchild.content]];
                            }
                            for (TFHppleElement *greatgrandchild in grandchild.children) {
                                if (greatgrandchild.content != nil) {
                                    [contentString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:greatgrandchild.content]];
                                }
                                for (TFHppleElement *greatgreatgrandchild in greatgrandchild.children) {
                                    if (greatgreatgrandchild.text != nil) {
                                        [contentString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:greatgreatgrandchild.text]];
                                    }
                                    if (greatgreatgrandchild.content != nil) {
                                        [contentString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:greatgreatgrandchild.content]];
                                    }
                                }
                            }
                        }
                    }
                }
            } else if ([element.tagName isEqualToString:@"a"]) {
                [contentString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:element.attributes[@"href"]]];
            } else if ([element.tagName isEqualToString:@"span"]) {
                if (element.text.length > 0) {
                    [contentString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:element.text]];
                } else if (element.content.length > 0) {
                    [contentString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:element.content]];
                }
            }
        }
        
        NSLog(@"final text: %@", contentString);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view hideToastActivity];
            self.textView.attributedText = contentString;
        });
    });
}

- (YNVImageTextAttachment *)textAttachmentWithImageURL:(NSString *)imageSrc {
    NSURL *imageURL = [NSURL URLWithString:imageSrc];
    NSData *imageData = [[NSData alloc] initWithContentsOfURL:imageURL];
    UIImage *image = [UIImage imageWithData:imageData];
    
    YNVImageTextAttachment *textAttachment = [[YNVImageTextAttachment alloc] init];
    textAttachment.image = [self imageWithImage:image scaledToWidth:self.view.frame.size.width];
    textAttachment.imageURLString = imageSrc;
    
    return textAttachment;
}

- (UIImage *)imageWithImage:(UIImage*)sourceImage scaledToWidth:(float)scaleWidth {
    float oldWidth = sourceImage.size.width;
    float scaleFactor = scaleWidth / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth - 10, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
