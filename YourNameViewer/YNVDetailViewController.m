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

@interface YNVDetailViewController ()

@end

@implementation YNVDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getPost];
}

- (void)getPost {
    [self.view makeToastActivity:CSToastPositionCenter];
    NSMutableString *contentString = self.titleString.mutableCopy;
    [contentString appendString:@"\n\n"];
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
        NSString *XPathQuery = @"//*[@id='dgn_content_de']/div[2]/div[1]/div";
        //*[@id="dgn_content_de"]/div[2]/div[1]/div/table/tbody/tr
        NSString *postURLString = [GALLERY_END_POINT stringByAppendingString:self.postLinkString];
        NSURL *postURL = [NSURL URLWithString:postURLString];
        NSData *postHTMLData = [NSData dataWithContentsOfURL:postURL];
        
        TFHpple *postParser = [TFHpple hppleWithHTMLData:postHTMLData];
        NSArray<TFHppleElement *> *parsedArray = [postParser searchWithXPathQuery:XPathQuery];
        
        TFHppleElement *element = parsedArray.firstObject;
        NSLog(@"<<<<<< %@ <> %@ <> %@ <> %@ >>>>>>>", element.text, element.tagName, element.attributes, element.children);
        
        TFHppleElement *tdElement = [[[parsedArray.firstObject firstChildWithTagName:@"table"] firstChildWithTagName:@"tr"] firstChildWithTagName:@"td"];
        NSLog(@"<<<<<< %@ <> %@ <> %@ <> %@ >>>>>>>", tdElement.text, tdElement.tagName, tdElement.attributes, tdElement.children);
        
        NSMutableArray<NSTextAttachment *> *attachmentArray = [NSMutableArray array];
        
        for (TFHppleElement *element in tdElement.children) {
            NSLog(@"<<<<<< %@ <> %@ <> %@ >>>>>>>", element.text, element.tagName, element.attributes);
            
            if (element.text.length > 0) {
                [contentString appendString:element.text];
            } else if ([element.tagName isEqualToString:@"br"]) {
                [contentString appendString:@"\n"];
            } else if ([element.tagName isEqualToString:@"text"]) {
                [contentString appendString:element.content];
            } else if ([element.tagName isEqualToString:@"div"] ||
                       [((TFHppleElement *)element.children.firstObject).tagName isEqualToString:@"img"]) {
                NSString *srcString = ((TFHppleElement *)element.children.firstObject).attributes[@"src"];
                
                if (srcString.length > 0) {
                    [contentString appendString:srcString];
                }
            }
        }
        
        NSLog(@"final text: %@", contentString);
        
        NSMutableAttributedString *contentAttributedString = [[NSMutableAttributedString alloc] initWithString:contentString];
        
        
        [contentAttributedString addAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:15.0f]}
                                         range:[contentString rangeOfString:self.titleString]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view hideToastActivity];
            self.textView.attributedText = contentAttributedString;
        });
    });
}
}

@end
