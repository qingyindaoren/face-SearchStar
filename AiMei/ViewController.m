//
//  ViewController.m
//  AiMei
//
//  Created by 美融城 on 2017/10/11.
//  Copyright © 2017年 美融城. All rights reserved.
//

#import "ViewController.h"
#import "FCDetectViewController.h"
#import "SearchFaceViewController.h"
#import "ObjectDetectViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    // Do any additional setup after loading the view, typically from a nib.

}
- (IBAction)pushToDetect:(UIButton *)sender {
        FCDetectViewController *detect = [FCDetectViewController new];
        [self.navigationController pushViewController:detect animated:YES];
}

- (IBAction)pushToSearch:(UIButton *)sender {
    SearchFaceViewController *search = [SearchFaceViewController new];
    [self.navigationController pushViewController:search animated:YES];
}
- (IBAction)pushToObjectDetect:(UIButton *)sender {
    ObjectDetectViewController *object = [ObjectDetectViewController new];
    [self.navigationController pushViewController:object animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
