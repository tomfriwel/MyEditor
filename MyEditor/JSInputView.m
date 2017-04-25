//
//  JSInputView.m
//  MyEditor
//
//  Created by tomfriwel on 08/11/2016.
//  Copyright © 2016 tom. All rights reserved.
//

#import "JSInputView.h"

@implementation JSInputView

- (instancetype)init {
    self = [super init];
    
    // Perform custom UI setup here
    //    self.nextKeyboardButton = [UIButton buttonWithType:UIButtonTypeSystem];
    //
    //    [self.nextKeyboardButton setTitle:NSLocalizedString(@"Next Keyboard", @"Title for 'Next Keyboard' button") forState:UIControlStateNormal];
    //    [self.nextKeyboardButton sizeToFit];
    //    self.nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = NO;
    //
    //    [self.nextKeyboardButton addTarget:self action:@selector(handleInputModeListFromView:withEvent:) forControlEvents:UIControlEventAllTouchEvents];
    //
    //    [self.view addSubview:self.nextKeyboardButton];
    //
    //    [self.nextKeyboardButton.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    //    [self.nextKeyboardButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    
    //    UIButton *button = [self createButtonWithTitle:@"A"];
    //    [self.view addSubview:button];
    //    self.view.backgroundColor = [UIColor clearColor];
//    UIColor *tintColor = [UIColor colorWithWhite:0.21 alpha:0.4];
    UIImage *image = [UIImage imageNamed:@"test"];
    image = [self imageByApplyingAlpha:image alpha:0.0];
    UIColor *background = [[UIColor alloc] initWithPatternImage:image];
    self.backgroundColor = background;
    //    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    //    NSLog(@"e=%d", self.view == self.inputView);
    
    NSArray *buttonTitles1 = @[@"Q", @"W", @"E", @"R", @"T", @"Y", @"U", @"I", @"O", @"P"];
    NSArray *buttonTitles2 = @[@"A", @"S", @"D", @"F", @"G", @"H", @"J", @"K", @"L"];
    NSArray *buttonTitles3 = @[@"CP", @"Z", @"X", @"C", @"V", @"B", @"N", @"M", @"BP"];
    NSArray *buttonTitles4 = @[@"CHG", @"SPACE", @"RETURN", @"DELETE"];
    
    UIView *row1 = [self createRowOfButtons:buttonTitles1];
    UIView *row2 = [self createRowOfButtons:buttonTitles2];
    UIView *row3 = [self createRowOfButtons:buttonTitles3];
    UIView *row4 = [self createRowOfButtons:buttonTitles4];
    
    [self addSubview:row1];
    [self addSubview:row2];
    [self addSubview:row3];
    [self addSubview:row4];
    
    
    [row1 setTranslatesAutoresizingMaskIntoConstraints:false];
    [row2 setTranslatesAutoresizingMaskIntoConstraints:false];
    [row3 setTranslatesAutoresizingMaskIntoConstraints:false];
    [row4 setTranslatesAutoresizingMaskIntoConstraints:false];
    
    [self addConstraintsToInputView:self rowViews:@[row1, row2, row3, row4]];
    
    self.backgroundColor = [UIColor redColor];
    
    return self;
}


- (UIImage *)imageByApplyingAlpha:(UIImage *)image alpha:(CGFloat) alpha {
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, image.size.width, image.size.height);
    
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    
    CGContextSetAlpha(ctx, alpha);
    
    CGContextDrawImage(ctx, area, image.CGImage);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma mark -
-(UIButton *)createButtonWithTitle:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(0, 0, 0, 0);
    [button setTitle:title forState:UIControlStateNormal];
    [button sizeToFit];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [button setTranslatesAutoresizingMaskIntoConstraints:false];
    button.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(didTapButton:) forControlEvents:UIControlEventTouchUpInside];
    
    button.layer.cornerRadius = 3;
    
    //    button.backgroundColor = [UIColor clearColor];
    return button;
}

-(UIView *)createRowOfButtons:(NSArray <NSString *>*)buttonTitles {
    NSMutableArray *buttons = [[NSMutableArray alloc] init];
    UIView *keyboardRowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
    
    keyboardRowView.backgroundColor = [UIColor clearColor];
    
    for (NSString *buttonTitle in buttonTitles){
        UIButton *button = [self createButtonWithTitle:buttonTitle];
        [buttons addObject:button];
        [keyboardRowView addSubview:button];
    }
    
    [self addIndividualButtonConstraints:buttons mainView:keyboardRowView];
    
    
    return keyboardRowView;
}

-(void)addIndividualButtonConstraints:(NSArray *)buttons mainView:(UIView *)mainView{
    NSEnumerator *e = [buttons objectEnumerator];
    id button;
    while (button = [e nextObject]) {
        NSInteger index = [buttons indexOfObject:button];
        
        NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:mainView attribute:NSLayoutAttributeTop multiplier:1.0 constant:1];
        NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:mainView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-1];
        
        NSLayoutConstraint *rightConstraint;
        
        //        var rightConstraint : NSLayoutConstraint!
        if (index == buttons.count - 1) {
            rightConstraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:mainView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-1];
            
        }else{
            UIButton *nextButton = buttons[index+1];
            rightConstraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:nextButton attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-1];
        }
        
        NSLayoutConstraint *leftConstraint;
        
        if (index == 0) {
            
            leftConstraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:mainView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:1];
            
        }else{
            UIButton *prevtButton = buttons[index-1];
            
            leftConstraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:prevtButton attribute:NSLayoutAttributeRight multiplier:1.0 constant:1];
            
            UIButton *firstButton = buttons[0];
            
            NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:firstButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:button attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
            
            [mainView addConstraint:widthConstraint];
        }
        
        [mainView addConstraints:@[topConstraint, bottomConstraint, rightConstraint, leftConstraint]];
    }
}

-(void)addConstraintsToInputView:(UIView *)inputView rowViews:(NSArray *)rowViews{
    NSEnumerator *e = [rowViews objectEnumerator];
    id rowView;
    while (rowView = [e nextObject]) {
        NSInteger index = [rowViews indexOfObject:rowView];
        NSLayoutConstraint *rightSideConstraint = [NSLayoutConstraint constraintWithItem:rowView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:inputView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-1];
        
        NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:rowView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:inputView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:1];
        
        [inputView addConstraints:@[leftConstraint, rightSideConstraint]];
        
        NSLayoutConstraint *topConstraint;
        
        if (index == 0) {
            
            topConstraint = [NSLayoutConstraint constraintWithItem:rowView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:inputView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
            
        }else{
            
            id prevRow = rowViews[index-1];
            topConstraint = [NSLayoutConstraint constraintWithItem:rowView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:prevRow attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
            
            id firstRow = rowViews[0];
            NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:firstRow attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:rowView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
            
            [inputView addConstraint:heightConstraint];
        }
        [inputView addConstraint:topConstraint];
        
        NSLayoutConstraint *bottomConstraint;
        
        if (index == rowViews.count - 1) {
            bottomConstraint = [NSLayoutConstraint constraintWithItem:rowView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:inputView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
            
        }else{
            
            id nextRow = rowViews[index+1];
            bottomConstraint = [NSLayoutConstraint constraintWithItem:rowView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:nextRow attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        }
        
        [inputView addConstraint:bottomConstraint];
    }
}

#pragma mark - tap event

-(void)didTapButton:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSString *title = [button titleForState:UIControlStateNormal];

//    [self insertText:title];
}

//-(void)didTapButton:(id)sender {
//    UIButton *button = (UIButton *)sender;
//    NSString *title = [button titleForState:UIControlStateNormal];
//
//    id proxy = self.textDocumentProxy;
//
//    [proxy insertText:title];
//}

//-(void)didTapButton:(id)sender {
//    UIButton *button = (UIButton *)sender;
//    NSString *title = [button titleForState:UIControlStateNormal];
//    
//    id proxy = self.textDocumentProxy;
//    
//    //    [proxy insertText:title];
//    
//    NSArray *specialArray = @[@"BP", @"RETURN", @"SPACE", @"CHG", @"DELETE"];
//    
//    switch ([specialArray indexOfObject:title]) {
//        case 0 :
//            [proxy deleteBackward];
//            break;
//        case 1 :
//            [proxy insertText:@"\n"];
//            break;
//        case 2 :
//            [proxy insertText:@" "];
//            break;
//        case 3 :
//            [self advanceToNextInputMode];
//            break;
//        case 4 :
//            [proxy deleteBackward];
//            break;
//        default :
//            [proxy insertText:title];
//            break;
//    }
//}

@end
