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
#import "IGHTMLQuery.h"

// Cell
#import "YNVDetailCommentCell.h"

static NSString *const cellIdentifier = @"detailCommentCell";

@interface YNVImageTextAttachment : NSTextAttachment

@property (strong, nonatomic) NSString *imageURLString;

@end

@implementation YNVImageTextAttachment

@end

@interface YNVCommentData : NSObject

@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSString *commenter;
@property (strong, nonatomic) NSString *dateString;

@end

@implementation YNVCommentData

@end

@interface YNVDetailViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic, nonnull) NSMutableArray<YNVCommentData *> *commentArray;

@end

@implementation YNVDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.commentArray = [NSMutableArray array];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(refresh)
                  forControlEvents:UIControlEventValueChanged];
    [self.scrollView addSubview:self.refreshControl];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100.0f;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.hidden = YES;
    
    [self getPostWithOtherLibraryThatNameIsIGHTMLQuery];
//    [self getPostHtml];
//    [self getPost];
}

- (void)refresh {
    self.textView.text = @"";

    [self getPostWithOtherLibraryThatNameIsIGHTMLQuery];
//    [self getPostHtml];
    [self.refreshControl endRefreshing];
}

- (void)getPostWithOtherLibraryThatNameIsIGHTMLQuery {
    [self.view makeToastActivity:CSToastPositionCenter];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *XPathQuery = @"//*[@id='dgn_content_de']/div[2]/div[1]";
        NSString *postURLString = [GALLERY_END_POINT stringByAppendingString:self.listData.postLink];
        NSURL *postURL = [NSURL URLWithString:postURLString];
        NSData *postHTMLData = [NSData dataWithContentsOfURL:postURL];
        
        IGXMLDocument *node = [[IGHTMLDocument alloc] initWithHTMLData:postHTMLData encoding:@"utf-8" error:nil];
        
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
        
        [[node queryWithXPath:XPathQuery] enumerateNodesUsingBlock:^(IGXMLNode *element, NSUInteger idx, BOOL *stop) {
            NSLog(@"enum = %@", element.html);
        }];
        
        IGXMLNode *element = [node queryWithXPath:XPathQuery].firstObject;
        
        [contentString appendAttributedString:[[NSAttributedString alloc] initWithData:[element.innerHtml dataUsingEncoding:NSUTF8StringEncoding]
                                                                               options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                                                         NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)}
                                                                    documentAttributes:nil
                                                                                 error:nil]];
        
        [contentString appendAttributedString:[[NSMutableAttributedString alloc]
                                               initWithString:[self.listData.title stringByAppendingString:@"\n"]
                                               attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:15.0f]}
                                               ]];
        
        [contentString appendAttributedString:[[NSMutableAttributedString alloc]
                                               initWithString:self.listData.postDateString
                                               attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14.0f],
                                                            NSForegroundColorAttributeName : [UIColor lightGrayColor]}
                                               ]];
        
        NSLog(@"final text: %@", contentString);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView beginAnimations:nil context:nil];
            self.textView.attributedText = contentString;
            [UIView commitAnimations];
            
            [self.view hideToastActivity];
            //            [self getComments];
        });
    });
}

- (void)getPostHtml {
    [self.view makeToastActivity:CSToastPositionCenter];
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
        NSString *XPathQuery = @"//*[@id='dgn_content_de']/div[2]/div[1]/div";
        NSString *postURLString = [GALLERY_END_POINT stringByAppendingString:self.listData.postLink];
        NSURL *postURL = [NSURL URLWithString:postURLString];
        NSData *postHTMLData = [NSData dataWithContentsOfURL:postURL];
        
        TFHpple *postParser = [TFHpple hppleWithHTMLData:postHTMLData];
        NSArray<TFHppleElement *> *parsedArray = [postParser searchWithXPathQuery:XPathQuery];
        
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
        
//        TFHppleElement *element = parsedArray.firstObject;
//        NSLog(@"<<<<<< %@ <> %@ <> %@ <> %@ >>>>>>>", element.text, element.tagName, element.attributes, element.children);
//        
//        if ([element firstChildWithTagName:@"a"] != nil) {
//            NSString *srcString = [[element firstChildWithTagName:@"a"] firstChildWithTagName:@"img"].attributes[@"src"];
//            
//            if (srcString.length > 0) {
//                [contentString appendAttributedString:[NSMutableAttributedString attributedStringWithAttachment:[self textAttachmentWithImageURL:srcString]]];
//            }
//        } else if ([element firstChildWithTagName:@"img"] != nil) {
//            NSString *srcString = [element firstChildWithTagName:@"img"].attributes[@"src"];
//            
//            if (srcString.length > 0) {
//                [contentString appendAttributedString:[NSMutableAttributedString attributedStringWithAttachment:[self textAttachmentWithImageURL:srcString]]];
//            }
//        }
//        
//        TFHppleElement *tdElement = [[[parsedArray.firstObject firstChildWithTagName:@"table"] firstChildWithTagName:@"tr"] firstChildWithTagName:@"td"];
//        NSLog(@"<<<<<< %@ <> %@ <> %@ <> %@ >>>>>>>", tdElement.text, tdElement.tagName, tdElement.attributes, tdElement.children);
////
//        for (TFHppleElement *element in tdElement.children) {
//            if ([element hasChildren]) {
//                for (TFHppleElement *childElement in element.children) {
//                    if ([childElement hasChildren]) {
//                        for (TFHppleElement *childChildElement in childElement.children) {
//                            if (![childChildElement hasChildren] && childChildElement.raw.length > 0) {
//                                [contentString appendAttributedString:[[NSAttributedString alloc] initWithData:[childChildElement.raw dataUsingEncoding:NSUTF8StringEncoding]
//                                                                                                       options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
//                                                                                                                 NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)}
//                                                                                            documentAttributes:nil
//                                                                                                         error:nil]];
//                            }
//                        }
//                    } else {
//                        if (childElement.raw.length > 0) {
//                        [contentString appendAttributedString:[[NSAttributedString alloc] initWithData:[childElement.raw dataUsingEncoding:NSUTF8StringEncoding]
//                                                                                               options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
//                                                                                                         NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)}
//                                                                                    documentAttributes:nil
//                                                                                                 error:nil]];
//                        }
//                    }
//                }
//            } else {
//                if (element.raw.length > 0) {
//                [contentString appendAttributedString:[[NSAttributedString alloc] initWithData:[element.raw dataUsingEncoding:NSUTF8StringEncoding]
//                                                                                       options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
//                                                                                                 NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)}
//                                                                            documentAttributes:nil
//                                                                                         error:nil]];
//                }
//            }
//        }
        
        [contentString appendAttributedString:[[NSAttributedString alloc] initWithData:[parsedArray.firstObject.raw dataUsingEncoding:NSUTF8StringEncoding]
                                                                               options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                                                         NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)}
                                                                    documentAttributes:nil
                                                                                 error:nil]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.textView.attributedText = contentString;
            
            [self.view hideToastActivity];
            //            [self getComments];
        });
    });
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
            
            if ([element.tagName isEqualToString:@"p"]) {
                if ([element.firstChild.tagName isEqualToString:@"img"]) {
                    NSString *srcString = element.firstChild.attributes[@"src"];
                    
                    if (srcString.length > 0) {
                        [contentString appendAttributedString:[NSMutableAttributedString attributedStringWithAttachment:[self textAttachmentWithImageURL:srcString]]];
                        [contentString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@" \n"]];
                    }
                }
                
                if (element.text.length > 0) {
                    [contentString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:element.text]];
                    [contentString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@" \n"]];
                } else {
                    [contentString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@" \n"]];
                }
            } else if ([element.tagName isEqualToString:@"br"]) {
                [contentString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@" \n"]];
            } else if ([element.tagName isEqualToString:@"text"]) {
                [contentString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:element.content]];
            } else if ([element.tagName isEqualToString:@"a"]) {
                NSString *srcString = element.firstChild.attributes[@"src"];
                NSString *childSrcString = [element firstChildWithTagName:@"img"].attributes[@"src"];
                
                if (srcString.length > 0) {
                    [contentString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:srcString]];
                } else if (childSrcString.length > 0) {
                    [contentString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:childSrcString]];
                } else {
                    [contentString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:element.attributes[@"href"]]];
                }
            } else if ([element.tagName isEqualToString:@"img"]) {
                NSString *srcString = element.attributes[@"src"];
                
                if (srcString.length > 0) {
                    [contentString appendAttributedString:[NSMutableAttributedString attributedStringWithAttachment:[self textAttachmentWithImageURL:srcString]]];
                    [contentString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@" \n"]];
                }
            } else if ([element.tagName isEqualToString:@"span"]) {
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
            } else if (element.attributes[@"app_paragraph"] != nil) {
                if ([((NSString *)element.attributes[@"app_paragraph"]) containsString:@"Dc_App_text"]) {
                    if (element.text.length > 0) {
                        [contentString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:element.text]];
                    }
                    if (element.content.length > 0) {
                        [contentString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:element.content]];
                    }
                }
                if ([((NSString *)element.attributes[@"app_paragraph"]) containsString:@"Dc_App_Img"]) {
                    NSString *srcString = [element firstChildWithTagName:@"img"].attributes[@"src"];
                    
                    if (srcString.length > 0) {
                        [contentString appendAttributedString:[NSMutableAttributedString attributedStringWithAttachment:[self textAttachmentWithImageURL:srcString]]];
                        [contentString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@" \n"]];
                    }
                }
            } else if ([element.tagName isEqualToString:@"div"] ||
                       [((TFHppleElement *)element.children.firstObject).tagName isEqualToString:@"img"] ||
                       [element firstChildWithTagName:@"img"]) {
                NSString *srcString = [element firstChildWithTagName:@"img"].attributes[@"src"];
                
                if (srcString.length > 0) {
                    [contentString appendAttributedString:[NSMutableAttributedString attributedStringWithAttachment:[self textAttachmentWithImageURL:srcString]]];
                    [contentString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@" \n"]];
                }
            } else if (element.hasChildren) {
                for (TFHppleElement *child in element.children) {
                    if (child.content != nil) {
                        [contentString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:child.content]];
                    }
                    if ([child.children count] != 0) {
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
            }
        }
        
        NSLog(@"final text: %@", contentString);
        
        [contentString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.textView sizeToFit];
            self.textView.attributedText = contentString;
            [self.textView sizeToFit];
            [self.textView layoutIfNeeded];
            [self.textView sizeToFit];
            
            [self.view hideToastActivity];
//            [self getComments];
        });
    });
}

- (void)getComments {
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
        NSString *XPathQuery = @"/html/head";
        NSString *postURLString = [GALLERY_END_POINT stringByAppendingString:
                                   [self.listData.postLink
                                    stringByReplacingCharactersInRange:[self.listData.postLink rangeOfString:@"view"]
                                    withString:@"comment_view"]
                                   ];
        NSURL *postURL = [NSURL URLWithString:postURLString];
        NSData *postHTMLData = [NSData dataWithContentsOfURL:postURL];
        
        TFHpple *postParser = [TFHpple hppleWithData:postHTMLData isXML:NO];
        NSArray<TFHppleElement *> *parsedArray = [postParser searchWithXPathQuery:XPathQuery];
        
        NSLog(@"%@", [postParser peekAtSearchWithXPathQuery:XPathQuery]);
        
        for (TFHppleElement *parsedElement in parsedArray) {
//            NSLog(@"<<<<<< %@ <> %@ <> %@ <> %@ >>>>>>>", parsedElement.text, parsedElement.tagName, parsedElement.attributes, parsedElement.children);
            if (parsedElement.content.length > 0) {
                NSLog(@"%@", parsedElement.content);
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view hideToastActivity];
            
            [self.tableView reloadData];
        });
    });
}

- (YNVImageTextAttachment *)textAttachmentWithImageURL:(NSString *)imageSrc {
    NSURL *imageURL = [NSURL URLWithString:imageSrc];
    NSData *imageData = [[NSData alloc] initWithContentsOfURL:imageURL];
    UIImage *image = [UIImage imageWithData:imageData];
    
    YNVImageTextAttachment *textAttachment = [[YNVImageTextAttachment alloc] init];
    textAttachment.image = image;
    
    if (image.size.width > self.view.frame.size.width) {
        textAttachment.image = [self imageWithImage:image scaledToWidth:self.view.frame.size.width];
    }
    
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

#pragma mark - Table view datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.commentArray.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"댓글";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YNVDetailCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    return cell;
}

#pragma mark - Table view delegate

@end
