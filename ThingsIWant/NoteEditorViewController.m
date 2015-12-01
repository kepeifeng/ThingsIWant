//
//  NoteEditorViewController.m
//  ThingsIWant
//
//  Created by Kent on 11/27/15.
//  Copyright © 2015 Kent. All rights reserved.
//

#import "NoteEditorViewController.h"

@interface NoteEditorViewController ()

@end

@implementation NoteEditorViewController{
    UITextField * titleField;
    UITextView * textView;
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
//        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerForKeyboardNotifications];
    
    self.view.backgroundColor = [UIColor whiteColor];

    if (!_note) {
        _note = [Note new];
    }

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"OK" style:(UIBarButtonItemStylePlain) target:self action:@selector(okButtonTapped:)];
    // Do any additional setup after loading the view.
    
    titleField = [[UITextField alloc] initWithFrame:(CGRectMake(10, CGRectGetMaxY(self.navigationController.navigationBar.frame), CGRectGetWidth(self.view.bounds) - 20, 44))];
    titleField.text = self.note.title;
    titleField.placeholder = @"Title";
    [self.view addSubview:titleField];
    
    textView = [[UITextView alloc] initWithFrame:(CGRectMake(10, CGRectGetMaxY(titleField.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(titleField.frame)))];
    textView.text = self.note.content;
    [self.view addSubview:textView];
    
    UIView * spliter = [[UIView alloc] initWithFrame:(CGRectMake(0, CGRectGetMaxY(titleField.frame), CGRectGetWidth(self.view.bounds), 1.0/[[UIScreen mainScreen] scale]))];
    spliter.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:spliter];
    

}

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWillShow:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGFloat duration = [info[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    textView.contentInset = UIEdgeInsetsMake(0, 0, kbSize.height, 0);
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGFloat duration = [info[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    textView.contentInset = UIEdgeInsetsZero;
    
}
-(void)okButtonTapped:(id)sender{
    
    self.note.title = titleField.text;
    self.note.content = textView.text;
    
    if ([self.delegate respondsToSelector:@selector(noteEditorViewController:didSavedNote:)]) {
        [self.delegate noteEditorViewController:self didSavedNote:self.note];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
