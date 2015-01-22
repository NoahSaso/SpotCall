#define log(z) NSLog(@"[SpotCall] %@", z)
#define sstr(z, ...) [NSString stringWithFormat:z, ##__VA_ARGS__]
#define empty(z) (!z || [(NSString *)z length] < 1)

@interface SBSearchField : UITextField
- (void)removeCallButton;
- (void)addCallButton;
@end

static UIButton *button = nil;

static SBSearchField* field;

%hook SBSearchField

- (id)initWithFrame:(CGRect)frame {
    field = %orig;
    // Activate listener in 1 second
    [self performSelector:@selector(registerCallListener) withObject:nil afterDelay:1];
    return field;
}

%new -(void)registerCallListener {
    // Add text change listener
    [self addTarget:self action:@selector(callTextDidChange) forControlEvents:UIControlEventEditingChanged];
}

%new -(void)callTextDidChange {
    // If contains letters, don't show button
    NSCharacterSet *notNumbers = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789;,+(- "] invertedSet];
    if((empty(self.text) || (!empty(self.text) && [self.text rangeOfCharacterFromSet:notNumbers].location != NSNotFound)) || self.text.length < 9)
        [self removeCallButton];
    else
        [self addCallButton];
}

%new -(void)removeCallButton {
    if(!button) return;
    // Remove
    log(@"Removing");
    [UIView animateWithDuration:0.3 animations: ^{
        button.alpha = 0;
    } completion: ^(BOOL){
        [button removeFromSuperview];
        [button release];
        button = nil;
    }];
}

%new -(void)addCallButton {
    if(button) return;
    // Add
    log(@"Adding");
    // Create button
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.alpha = 0;
    // Set frame
    button.frame = CGRectMake(self.frame.size.width - 70, (self.frame.size.height / 2) - 11.5, 23, 23);
    // Set image
    [button setImage:[UIImage imageWithContentsOfFile:@"/Applications/MobilePhone.app/AppIcon29x29@2x.png"] forState:UIControlStateNormal];
    // Add target
    [button addTarget:self action:@selector(callNow) forControlEvents:UIControlEventTouchUpInside];
    // Round
    button.layer.cornerRadius = 10;
    button.layer.masksToBounds = YES;

    // Present
    [self addSubview:button];
    [UIView animateWithDuration:0.3 animations: ^{
        button.alpha = 1;
    }];
}

%new -(void)callNow {
    // If no text, stop
    if(empty(self.text)) return;
    // Remove extra characters
    NSString *number = [[[[self.text stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@""] stringByReplacingOccurrencesOfString:@"(" withString:@""] stringByReplacingOccurrencesOfString:@")" withString:@""];
    log(sstr(@"Calling: %@", number));
    // Call
    NSURL *numberURL = [NSURL URLWithString:sstr(@"tel:%@", number)];
    if([[UIApplication sharedApplication] canOpenURL:numberURL])
        [[UIApplication sharedApplication] openURL:numberURL];
}

%end
