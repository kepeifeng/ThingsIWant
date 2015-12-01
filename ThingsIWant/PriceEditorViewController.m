//
//  PriceEditorViewController.m
//  ThingsIWant
//
//  Created by Kent on 11/30/15.
//  Copyright © 2015 Kent. All rights reserved.
//

#import "PriceEditorViewController.h"

@interface PriceEditorViewController ()

@end

@implementation PriceEditorViewController{
    QEntryElement * priceElement;
    QEntryElement * noteElement;
    
}

- (instancetype)init
{
    QRootElement * root = [[QRootElement alloc] init];
    root.grouped = YES;
    
    self = [super initWithRoot:root];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!_price) {
        _price = [AKPrice new];
    }
    [self setupRootElement];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"OK" style:(UIBarButtonItemStylePlain) target:self action:@selector(okButtonTapped:)];
    // Do any additional setup after loading the view.
}

-(void)okButtonTapped:(id)sender{

    if ([self.delegate respondsToSelector:@selector(priceEditorViewController:didSavedPrice:)]) {
        [self.delegate priceEditorViewController:self didSavedPrice:self.price];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupRootElement{

    QRootElement * root = self.root;
    QSection * section = [[QSection alloc] init];
    [root addSection:section];
    __weak PriceEditorViewController * weakSelf = self;
    priceElement = [[QEntryElement alloc] initWithTitle:@"Price" Value:[@(self.price.value) stringValue] Placeholder:nil];
    priceElement.keyboardType = UIKeyboardTypeDecimalPad;
    [priceElement setOnValueChanged:^(QEntryElement * element) {
        weakSelf.price.value = [element.textValue floatValue];
    }];
    [section addElement:priceElement];
    
    QSection * additionSection = [[QSection alloc] init];
    [root addSection:additionSection];
    
    noteElement = [[QEntryElement alloc] initWithTitle:@"Note" Value:self.price.note Placeholder:nil];
    [noteElement setOnValueChanged:^(QEntryElement * element) {
        weakSelf.price.note = (NSString *)element.textValue;
    }];
    [additionSection addElement:noteElement];
    
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
