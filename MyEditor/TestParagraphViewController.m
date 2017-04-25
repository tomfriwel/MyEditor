//
//  TestParagraphViewController.m
//  MyEditor
//
//  Created by tomfriwel on 17/02/2017.
//  Copyright © 2017 tom. All rights reserved.
//

#import "TestParagraphViewController.h"

@interface TestParagraphViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation TestParagraphViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)logAction:(id)sender {
    
    
    NSString *textViewString = self.textView.text;
    NSRange selectedRange = [self.textView selectedRange];
    NSRange paragraphRange = [self.textView.text paragraphRangeForRange:selectedRange];
    
    NSRange test = [textViewString paragraphRangeForRange:NSMakeRange(2, 0)];
    
    NSLog(@"%@", [textViewString substringWithRange:paragraphRange]);
    
    [textViewString enumerateSubstringsInRange:selectedRange options:NSStringEnumerationByParagraphs usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        NSRange pRange = [textViewString paragraphRangeForRange:substringRange];
        NSLog(@"enumerate:%@", [textViewString substringWithRange:pRange]);
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
