//
//  LoginViewController.m
//  ThingsIWant
//
//  Created by Kent on 12/1/15.
//  Copyright © 2015 Kent. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import <AVOSCloud.h>

@interface LoginViewController ()

@end

@implementation LoginViewController

- (instancetype)init
{
    QRootElement * rootElement = [[QRootElement alloc] init];
    rootElement.grouped = YES;
    self = [super initWithRoot:rootElement];
    if (self) {
        
    }
    return self;
}

-(void)setupTableView{

    QRootElement * root = self.root;
    
    QSection * section = [[QSection alloc] init];
    [root addSection:section];
    
    UIView * headerView = [[UIView alloc] initWithFrame:(CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 200))];
    section.headerView = headerView;
    
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
    [forgotPasswordButton setTitle:NSLocalizedString(@"Forgot Password?",nil) forState:(UIControlStateNormal)];
    [footerView addSubview:forgotPasswordButton];
    
    
    QButtonElement * loginElement = [[QButtonElement alloc] initWithTitle:NSLocalizedString(@"Login",nil)];
    [loginElement setOnSelected:^{
        NSString * username = usernameElement.textValue;
        NSString * password = passwordElement.textValue;
        if (username.length == 0 || password.length == 0) {
            return;
        }
        [self loginWithUsername:username password:password];
    }];
    [actionSection addElement:loginElement];

    
}

-(void)loginWithUsername:(NSString *)username password:(NSString *)password{

    [AVUser logInWithUsernameInBackground:username password:password block:^(AVUser *user, NSError *error) {
        if (user != nil) {
            
        } else {
            
        }
    }];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupTableView];
    
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back",nil) style:(UIBarButtonItemStylePlain) target:self action:@selector(backButtonTapped:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Register" style:UIBarButtonItemStylePlain target:self action:@selector(registerButtonTapped:)];
}

-(void)backButtonTapped:(id)sender{
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)registerButtonTapped:(id)sender{
    
    RegisterViewController * registerViewController = [[RegisterViewController alloc] init];
    [self.navigationController pushViewController:registerViewController animated:YES];

}

@end
