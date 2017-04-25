//
//  DemoViewController.m
//  MyEditor
//
//  Created by tomfriwel on 08/11/2016.
//  Copyright © 2016 tom. All rights reserved.
//

#import "DemoViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>

#import "JSInputView.h"
#import "MMNumberKeyboard.h"

@interface DemoViewController () <MMNumberKeyboardDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    MMNumberKeyboard *keyboard = [[MMNumberKeyboard alloc] initWithFrame:CGRectZero];
    keyboard.allowsDecimalPoint = YES;
    keyboard.delegate = self;
    
    self.textView.inputView = keyboard;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShowOrHide:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShowOrHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (NSRange) selectedRangeInTextView:(UITextView*)textView
{
    UITextPosition* beginning = textView.beginningOfDocument;
    
    UITextRange* selectedRange = textView.selectedTextRange;
    UITextPosition* selectionStart = selectedRange.start;
    UITextPosition* selectionEnd = selectedRange.end;
    
    const NSInteger location = [textView offsetFromPosition:beginning toPosition:selectionStart];
    const NSInteger length = [textView offsetFromPosition:selectionStart toPosition:selectionEnd];
    
    return NSMakeRange(location, length);
}

-(NSString *)convertAttr2HTML:(NSAttributedString *)attr{
    NSDictionary *documentAttributes = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
    
    NSData *htmlData = [attr dataFromRange:NSMakeRange(0, attr.length) documentAttributes:documentAttributes error:NULL];
    NSString *htmlString = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
    
    NSLog(@"htmlString:%@", htmlString);
    NSLog(@"attributedString:%@", attr);
    
    return htmlString;
}

#pragma mark - test button
- (IBAction)addPicAction:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}
- (IBAction)toHTMLAction:(id)sender {
    [self convertAttr2HTML:self.textView.attributedText];
}

//#pragma mark - UITextViewDelegate
//
//-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
//    [[NSNotificationCenter defaultCenter] postNotificationName:UIKeyboardWillShowNotification object:nil];
//    return YES;
//}
//
//-(BOOL)textViewShouldEndEditing:(UITextView *)textView{
//    [[NSNotificationCenter defaultCenter] postNotificationName:UIKeyboardWillHideNotification object:nil];
//    return YES;
//}

#pragma mark - Keyboard status

- (void)keyboardShowOrHide:(NSNotification *)notification {
    // User Info
    NSDictionary *info = notification.userInfo;
    CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    int curve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    CGFloat keyboardHeight = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    // Correct Curve
    UIViewAnimationOptions animationOptions = curve << 16;
    
    //    CGRect containerFrame = self.view.frame;
    
    if ([notification.name isEqualToString:UIKeyboardDidShowNotification]) {
        [UIView animateWithDuration:duration delay:0 options:animationOptions animations:^{
            self.bottomConstraint.constant = keyboardHeight;
        } completion:nil];
    }
    else {
        
        [UIView animateWithDuration:duration delay:0 options:animationOptions animations:^{
            self.bottomConstraint.constant = 0;
        } completion:nil];
    }
    
}


#pragma mark - MMNumberKeyboardDelegate.

- (BOOL)numberKeyboardShouldReturn:(MMNumberKeyboard *)numberKeyboard {
    // Do something with the done key if neeed. Return YES to dismiss the keyboard.
    return YES;
}

#pragma mark UIImagePickerControllerDelegate

- (void)_addAttachmentFromAsset:(ALAsset *)asset; {
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    NSMutableData *data = [NSMutableData dataWithLength:[rep size]];
    
    NSError *error = nil;
    if ([rep getBytes:[data mutableBytes] fromOffset:0 length:[rep size] error:&error] == 0) {
        NSLog(@"error getting asset data %@", [error debugDescription]);
    } else {
        
        UITextRange *selectedTextRange = [self.textView selectedTextRange];
        if (!selectedTextRange) {
            UITextPosition *endOfDocument = [self.textView endOfDocument];
            selectedTextRange = [self.textView textRangeFromPosition:endOfDocument toPosition:endOfDocument];
            NSLog(@"no select:%@", selectedTextRange);
        }else {
            NSLog(@"exist select:%@", selectedTextRange);
        }
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.attributedText];
        
        //image attachment
        NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
        textAttachment.image = [UIImage imageWithData:data];
        
        CGFloat oldWidth = textAttachment.image.size.width;
        //I'm subtracting 10px to make the image display nicely, accounting
        //for the padding inside the textView
        CGFloat scaleFactor = oldWidth / (self.textView.frame.size.width - 10);
        textAttachment.image = [UIImage imageWithCGImage:textAttachment.image.CGImage scale:scaleFactor orientation:UIImageOrientationUp];
        
        NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
        
        NSMutableAttributedString *mattrStringWithImage = [[NSMutableAttributedString alloc] initWithString:@"\n"];
        [mattrStringWithImage insertAttributedString:attrStringWithImage atIndex:0];
        
        [mattrStringWithImage insertAttributedString:[[NSAttributedString alloc] initWithString:@"\n"] atIndex:0];
        
        
//        [attributedString replaceCharactersInRange:NSMakeRange(6, 1) withAttributedString:attrStringWithImage];
        [attributedString replaceCharactersInRange:[self selectedRangeInTextView:self.textView] withAttributedString:mattrStringWithImage];
        
        
        //finish
        self.textView.attributedText = attributedString;
        
        
        
        //        NSFileWrapper *wrapper = [[NSFileWrapper alloc] initRegularFileWithContents:data];
        //        wrapper.filename = [[rep url] lastPathComponent];
//        UIImage *img=[UIImage imageWithData:data];
//        NSArray *_paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString * _documentDirectory = [[NSString alloc] initWithString:[_paths objectAtIndex:0]];
//        
//        //[[AppDelegate documentDirectory] stringByAppendingPathComponent:@"tmp.jpg"];
//        
//        UITextRange *selectedTextRange = [self.textView selectedTextRange];
//        if (!selectedTextRange) {
//            UITextPosition *endOfDocument = [self.textView endOfDocument];
//            selectedTextRange = [self.textView textRangeFromPosition:endOfDocument toPosition:endOfDocument];
//        }
//        UITextPosition *startPosition = [selectedTextRange start] ; // hold onto this since the edit will drop
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init] ;
    [library assetForURL:[info objectForKey:UIImagePickerControllerReferenceURL]
             resultBlock:^(ALAsset *asset){
                 // This get called asynchronously (possibly after a permissions question to the user).
                 //insert to textview
                 [self _addAttachmentFromAsset:asset];
             }
            failureBlock:^(NSError *error){
                NSLog(@"error finding asset %@", [error debugDescription]);
            }];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
