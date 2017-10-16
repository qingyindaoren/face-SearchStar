//
//  ObjectDetectViewController.m
//  AiMei
//
//  Created by 美融城 on 2017/10/13.
//  Copyright © 2017年 美融城. All rights reserved.
//

#import "ObjectDetectViewController.h"
#import "AFAppDotNetAPIClient.h"

@interface ObjectDetectViewController ()
@property (nonatomic,strong)UILabel *detailText;

@end

@implementation ObjectDetectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UILabel * detail = [[UILabel alloc]init];
    [self.view addSubview:detail];
    self.detailText = detail;
    detail.textColor = [UIColor darkGrayColor];
    detail.font = [UIFont systemFontOfSize:16];
    detail.numberOfLines = 0;
    
    
}
- (void)handleImage:(UIImage *)image{
   
   
    self.imageView.image = image;

    
    __weak typeof(self) weakSelf = self;
 MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //需要获取的属性
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:kApiKey forKey:@"api_key"];
    [param setValue:kApiSecret forKey:@"api_secret"];
    UIImage *midImage = [self imageWithImageSimple:image scaledToSize:CGSizeMake(210.0, 210.0)];
    NSData* imageData = UIImageJPEGRepresentation(midImage,1.0);
    //生成图片的文件名，格式为：时间.jpg
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];

    [[AFAppDotNetAPIClient sharedZCClient] POST:@"beta/detectsceneandobject" parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        //附加数据流
        [formData appendPartWithFileData:imageData name:@"image_file" fileName:fileName mimeType:@"image/jpg"];
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        NSLog(@"%@",responseObject);
        NSDictionary *detail = responseObject;
        [self showDetail:detail];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        hud.label.text = @"网络错误";
        [hud hideAnimated:YES afterDelay:1.0];
    }];


}
-(void)showDetail:(NSDictionary*)dict{
    NSArray *object = dict[@"objects"];
    NSArray *scenes = dict[@"scenes"];
   NSMutableString *detailStr = [NSMutableString string];
    if (object.count==0) {
        [detailStr appendFormat:@"没能识别出物体"];
        
    }else{
        for (NSDictionary *d in object) {
            [detailStr appendFormat:@"物体: %@",d[@"value"]];
             [detailStr appendFormat:@"  概率: %.2lf\n",[d[@"confidence"] floatValue]];
        }
    }
    if (scenes.count==0) {
        [detailStr appendFormat:@"\n\n没能识别出场景"];
        
    }else{
        [detailStr appendFormat:@"\n"];
        for (NSDictionary *d in scenes) {
            [detailStr appendFormat:@"场景: %@",d[@"value"]];
            [detailStr appendFormat:@"  概率: %.2lf\n",[d[@"confidence"] floatValue]];
        }
    }
    self.detailText.text = detailStr;
    self.detailText.frame = CGRectMake(10, self.view.bounds.size.height*0.4+10+64, self.view.bounds.size.width-20, 0);
    [self.detailText sizeToFit];
    
}
- (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
