//
//  CCGrowingTextView.m
//  GrowingTextViewExample
//
//  Created by ziryanov on 29/10/13.
//  Copyright (c) 2013 ziryanov. All rights reserved.
//

#import "CCGrowingTextView.h"

#define CCGrowingTextView_isIOS7 ( [[[UIDevice currentDevice] systemVersion] integerValue] >= 7 )

@interface CCGrowingTextView()

@property (nonatomic) id CCGrowingTextViewTextChangedNotification;
@property (nonatomic) UILabel *placeholderLabel;
@property (nonatomic) CGFloat maxHeight;

@end

@implementation CCGrowingTextView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self CCGrowingTextView_initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self CCGrowingTextView_initialize];
    }
    return self;
}

- (void)CCGrowingTextView_initialize
{
    __weak CCGrowingTextView *wself = self;
    _CCGrowingTextViewTextChangedNotification = [[NSNotificationCenter defaultCenter] addObserverForName:UITextViewTextDidChangeNotification object:self queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [wself CCGrowingTextView_updatePlaceholder];
    }];
    
    _placeholderLabel = [UILabel new];
    _placeholderLabel.numberOfLines = 0;
    _placeholderLabel.backgroundColor = [UIColor clearColor];
    _placeholderLabel.font = self.font;
    _placeholderLabel.textColor = [[self.class appearance] placeholderColor] ?: [UIColor lightGrayColor];
    [self addSubview:_placeholderLabel];

    [self CCGrowingTextView_updatePlaceholderFrame];
    [self CCGrowingTextView_updatePlaceholder];
    
    [self addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:0];
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"contentSize"];
    [[NSNotificationCenter defaultCenter] removeObserver:_CCGrowingTextViewTextChangedNotification];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self invalidateIntrinsicContentSize];
}

- (CGSize)intrinsicContentSize
{
    CGFloat height = self.maxNumberOfLine ? MAX(_placeholderLabel.frame.size.height, MIN(self.contentSize.height, self.maxHeight)) : self.contentSize.height;
    return CGSizeMake(UIViewNoIntrinsicMetric, height);
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    
    _placeholderLabel.hidden = text.length > 0;
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    [super setAttributedText:attributedText];
    
    _placeholderLabel.hidden = attributedText.string.length > 0;
}

- (void)CCGrowingTextView_recalculateMaxHeight
{
    NSString* text = @"1";
    for (NSUInteger i = 1; i < _maxNumberOfLine; i++)
        text = [text stringByAppendingString:@"\n1"];
    NSString *originalText = self.text;
    self.text = text;
    self.maxHeight = [self sizeThatFits:CGSizeMake(self.frame.size.width, MAXFLOAT)].height;
    self.text = originalText;
}

- (void)setMaxNumberOfLine:(NSUInteger)maxNumberOfLine
{
    _maxNumberOfLine = maxNumberOfLine;
    [self CCGrowingTextView_recalculateMaxHeight];
}

- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    [self CCGrowingTextView_recalculateMaxHeight];
    _placeholderLabel.font = font;
    [self CCGrowingTextView_updatePlaceholderFrame];
}

- (void)setContentOffset:(CGPoint)contentOffset
{
    if (fabs(self.contentSize.height - self.bounds.size.height) < 1 && contentOffset.y > 0)
        contentOffset.y = 0;
    super.contentOffset = contentOffset;
}

- (void)setContentInset:(UIEdgeInsets)contentInset
{
    if (UIEdgeInsetsEqualToEdgeInsets(self.contentInset, contentInset))
        return;
    [super setContentInset:contentInset];
    [self CCGrowingTextView_recalculateMaxHeight];
}

- (void)setTextContainerInset:(UIEdgeInsets)textContainerInset
{
    if (UIEdgeInsetsEqualToEdgeInsets(self.textContainerInset, textContainerInset))
        return;
    [super setTextContainerInset:textContainerInset];
    [self CCGrowingTextView_updatePlaceholderFrame];
}

- (void)setBounds:(CGRect)bounds
{
    BOOL widthChanged = bounds.size.width != self.bounds.size.width;
    [super setBounds:bounds];
    if (!widthChanged)
        return;
    [self CCGrowingTextView_updatePlaceholderFrame];
    [self CCGrowingTextView_recalculateMaxHeight];
}

- (void)CCGrowingTextView_updatePlaceholderFrame
{
    CGFloat xOrigin = CCGrowingTextView_isIOS7 ? 5 : 8;
    CGFloat yOrigin = 0;
    CGFloat width = self.frame.size.width - xOrigin * 2;
    CGFloat maxHeight = self.frame.size.height;

    if ([self respondsToSelector:@selector(textContainerInset)])
    {
        xOrigin += self.textContainerInset.left;
        yOrigin += self.textContainerInset.top;
        width -= self.textContainerInset.left + self.textContainerInset.right;
        maxHeight -= self.textContainerInset.top + self.textContainerInset.bottom;
    }

    CGFloat height = [_placeholderLabel sizeThatFits:CGSizeMake(width, MAXFLOAT)].height;
    height = MIN(height, maxHeight);

    _placeholderLabel.frame = CGRectMake(xOrigin, yOrigin, width, height);
}

- (void)CCGrowingTextView_updatePlaceholder
{
    _placeholderLabel.hidden = self.text.length > 0;
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor
{
    _placeholderLabel.textColor = placeholderColor;
}

- (UIColor *)placeholderColor
{
    return _placeholderLabel.textColor;
}

- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholderLabel.text = placeholder;
    [self CCGrowingTextView_updatePlaceholderFrame];
}

- (NSString *)placeholder
{
    return _placeholderLabel.text;
}

@end
