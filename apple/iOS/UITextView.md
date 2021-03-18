# UITextView

### lineFragmentPadding

```
// Default value: 5.0  The layout padding at the beginning and end of the line fragment rects insetting the layout width available for the contents.  This value is utilized by NSLayoutManager for determining the layout width.
@property (NS_NONATOMIC_IOSONLY) CGFloat lineFragmentPadding;
```



### 获取每一行的文本

```objective-c
+ (NSArray *)getSeparatedLines:(id)textViewOrLabel {
    if ([textViewOrLabel isKindOfClass:[UITextView class]] || [textViewOrLabel isKindOfClass:[UILabel class]]) {
        NSString *text;
        UIFont   *font;
        CGRect    rect;
        
        if ([textViewOrLabel isKindOfClass:[UILabel class]]) {
            UILabel *label = textViewOrLabel;
            text = label.text;
            font = label.font;
            rect = label.frame;
        } else {
            UITextView *textView = textViewOrLabel;
            text = textView.text;
            font = textView.font;
            rect = textView.frame;
            
            CGFloat padding = textView.textContainer.lineFragmentPadding;
            rect.size.width = rect.size.width - textView.textContainerInset.left - textView.textContainerInset.right - 2 * padding;
        }
        
        CTFontRef myFont = (__bridge CTFontRef)font;
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:text];
        [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)myFont range:NSMakeRange(0, attStr.length)];

        CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attStr);

        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectMake(0,0,rect.size.width,100000));

        CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);

        NSArray *lines = (__bridge NSArray *)CTFrameGetLines(frame);
        NSMutableArray *linesArray = [[NSMutableArray alloc]init];

        for (id line in lines)
        {
            CTLineRef lineRef = (__bridge CTLineRef )line;
            CFRange lineRange = CTLineGetStringRange(lineRef);
            NSRange range = NSMakeRange(lineRange.location, lineRange.length);

            NSString *lineString = [text substringWithRange:range];
            [linesArray addObject:lineString];
        }
        return linesArray;
    } else {
        NSLog(@"参数必须是 UITextView 或者 UILabel");
        return @[];
    }
}
```

