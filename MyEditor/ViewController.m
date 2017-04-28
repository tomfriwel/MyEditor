//
//  ViewController.m
//  MyEditor
//
//  Created by tomfriwel on 31/10/2016.
//  Copyright © 2016 tom. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import <WebViewJavascriptBridge.h>
#import "MMNumberKeyboard.h"
#import "JSInputView.h"
#import "MyWebView.h"

/**
 去除webview keyboard上面自带的bar
 */

@interface UIWebView (HackishAccessoryHiding)

@property (nonatomic, assign) BOOL hidesInputAccessoryView;

@end

@implementation UIWebView (HackishAccessoryHiding)

static const char *const hackishFixClassName = "UIWebBrowserViewMinusAccessoryView";
static Class hackishFixClass = Nil;

- (UIView *)hackishlyFoundBrowserView {
    UIScrollView *scrollView = self.scrollView;
    
    UIView *browserView = nil;
    for (UIView *subview in scrollView.subviews) {
        if ([NSStringFromClass([subview class]) hasPrefix:@"UIWebBrowserView"]) {
            browserView = subview;
            break;
        }
    }
    return browserView;
}

- (id)methodReturningNil {
    return nil;
}

- (void)ensureHackishSubclassExistsOfBrowserViewClass:(Class)browserViewClass {
    if (!hackishFixClass) {
        Class newClass = objc_allocateClassPair(browserViewClass, hackishFixClassName, 0);
        newClass = objc_allocateClassPair(browserViewClass, hackishFixClassName, 0);
        IMP nilImp = [self methodForSelector:@selector(methodReturningNil)];
        class_addMethod(newClass, @selector(inputAccessoryView), nilImp, "@@:");
        objc_registerClassPair(newClass);
        
        hackishFixClass = newClass;
    }
}

- (BOOL) hidesInputAccessoryView {
    UIView *browserView = [self hackishlyFoundBrowserView];
    return [browserView class] == hackishFixClass;
}

- (void) setHidesInputAccessoryView:(BOOL)value {
    UIView *browserView = [self hackishlyFoundBrowserView];
    if (browserView == nil) {
        return;
    }
    [self ensureHackishSubclassExistsOfBrowserViewClass:[browserView class]];
    
    if (value) {
        object_setClass(browserView, hackishFixClass);
    }
    else {
        Class normalClass = objc_getClass("UIWebBrowserView");
        object_setClass(browserView, normalClass);
    }
    [browserView reloadInputViews];
}

@end



@interface ViewController () <UIWebViewDelegate, UIScrollViewDelegate, MMNumberKeyboardDelegate>

@property (weak, nonatomic) IBOutlet MyWebView *webView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) UIView *inputViewStore;

@property WebViewJavascriptBridge* bridge;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Create and configure the keyboard.
    MMNumberKeyboard *keyboard = [[MMNumberKeyboard alloc] initWithFrame:CGRectZero];
    keyboard.allowsDecimalPoint = YES;
    keyboard.delegate = self;
    self.inputViewStore = self.textView.inputView;
    self.textView.inputView = keyboard;
    
    self.webView.scrollView.bounces = NO;
    self.webView.hidesInputAccessoryView = YES;
    self.webView.scrollView.delegate = self;
    self.webView.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:self.webView];
    [self.bridge setWebViewDelegate:self];
    [self registerHandlers];
    
    [self loadWeb];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShowOrHide:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShowOrHide:) name:UIKeyboardWillHideNotification object:nil];
}
- (IBAction)returnButton:(id)sender {
    self.textView.inputView = nil;
    if (self.inputViewStore) {
        self.textView.inputView = self.inputViewStore;
    }
}

#pragma mark - MMNumberKeyboardDelegate.

- (BOOL)numberKeyboardShouldReturn:(MMNumberKeyboard *)numberKeyboard
{
    // Do something with the done key if neeed. Return YES to dismiss the keyboard.
    return YES;
}

-(void)loadWeb{
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"html" inDirectory:@"editor"]];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
//    [self initContext];
}

-(void)registerHandlers{
    [self.bridge registerHandler:@"SaveData" handler:^(id data, WVJBResponseCallback responseCallback) {
        responseCallback(@"save success");
    }];
}

- (IBAction)saveAction:(id)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *htmlString = [self.webView stringByEvaluatingJavaScriptFromString:@"getHtmlString();"];
    [userDefaults setObject:htmlString forKey:@"htmlString"];
}

- (IBAction)setStyleAction:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
            [self.bridge callHandler:@"SetSelectionColor" data:@{@"color":@"#f00"} responseCallback:^(id responseData) {
                NSLog(@"%@", responseData);
            }];
            break;
            
        case 1:
            [self.bridge callHandler:@"SetFontFamily" data:@{@"fontName":@"Menlo"} responseCallback:^(id responseData) {
                NSLog(@"%@", responseData);
            }];
            break;
            
        default:
            break;
    }
}

-(void)initContext{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *htmlString = [userDefaults objectForKey:@"htmlString"];
    
    if (htmlString && ![htmlString isEqual:@""]) {
        [self.bridge callHandler:@"InitData" data:@{@"content":htmlString} responseCallback:^(id responseData) {
            NSLog(@"InitData:%@", responseData);
        }];
//        [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"initContext('%@');", htmlString]];
    }
    
}


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

#pragma mark - UIWebViewDelegate

-(void)webViewDidStartLoad:(UIWebView *)webView{
    
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [self initContext];
}

#pragma mark - UIScrollViewDelegate


@end
