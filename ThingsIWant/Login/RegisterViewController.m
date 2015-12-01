//
// Created by Kent on 12/1/15.
// Copyright (c) 2015 Kent. All rights reserved.
//

#import "RegisterViewController.h"
#import <AVOSCloud.h>

@implementation RegisterViewController {

}

-(instancetype)init{
    QRootElement * root = [[QRootElement alloc] init];
    root.grouped = YES;
    self = [super initWithRoot:root];
    if(self){


    }
    return self;

}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupTableView];
}

- (void)setupTableView {

    QRootElement * root = self.root;

    QSection * section = [[QSection alloc] init];
    [root addSection:section];

/*    UIView * headerView = [[UIView alloc] initWithFrame:(CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 300))];
    section.headerView = headerView;*/

    QEntryElement * usernameElement = [[QEntryElement alloc] initWithTitle:nil Value:nil Placeholder:NSLocalizedString(@"Username / Email",nil)];
    [section addElement:usernameElement];

    QEntryElement * passwordElement = [[QEntryElement alloc] initWithTitle:nil Value:nil Placeholder:NSLocalizedString(@"Password",nil)];
    passwordElement.secureTextEntry = YES;
    [section addElement:passwordElement];
    

    QSection * actionSection = [[QSection alloc] init];
    [root addSection:actionSection];

    UIView * footerView = [[UIView alloc] initWithFrame:(CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 40))];
    actionSection.footerView = footerView;
    UIButton * forgotPasswordButton = [[UIButton alloc] initWithFrame:(CGRectMake(CGRectGetWidth(footerView.bounds) - 100, 0, 100, CGRectGetHeight(footerView.bounds)))];
    [forgotPasswordButton setTitle:NSLocalizedString(@"Terms",nil) forState:(UIControlStateNormal)];
    [footerView addSubview:forgotPasswordButton];


    QButtonElement *registerElement = [[QButtonElement alloc] initWithTitle:NSLocalizedString(@"Register",nil)];
    [actionSection addElement:registerElement];
    [registerElement setOnSelected:^{
        NSLog(@"registerElement");
        NSString * username = usernameElement.textValue;
        NSString * password = passwordElement.textValue;
        if (username.length == 0 || password.length == 0) {
            return;
        }

        [self registerWithUserName:username password:password email:nil];
    }];

}

-(void)registerWithUserName:(NSString *)username password:(NSString *)password email:(NSString *)email{

    AVUser *user = [AVUser user];
    user.username = username;
    user.password =  password;
    user.email = email;
//    [user setObject:@"186-1234-0000" forKey:@"phone"];
    
    [self startLoading];
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        [self stopLoadingAnimated:NO];
        if (succeeded) {
            
            [self showCheckmark];
            AVUser * user = [AVUser currentUser];
            NSLog(@"current user: %@", user.username);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:YES completion:NULL];
            });
            
        } else {
            [self showMessage:error.localizedDescription withStatus:(LAStatusError)];
        }
    }];
}

@end