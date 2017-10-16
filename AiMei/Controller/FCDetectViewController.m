//
//  FCDetectViewController.m
//  FaceSDKDemo
//
//  Created by Yang Yunxing on 2017/6/27.
//  Copyright © 2017年 Yang Yunxing. All rights reserved.
//

#import "FCDetectViewController.h"
#import "MBProgressHUD.h"
#import "UIImage+FCExtension.h"
#import "FCPPSDK.h"
#import "UIColor+RCColor.h"

@interface FaceCell : UICollectionViewCell
@property (strong , nonatomic) UIImage *fullImage;
@property (strong , nonatomic) NSDictionary *faceInfo;
@property (weak, nonatomic) IBOutlet UILabel *detail;
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@end

@implementation FaceCell



- (void)setFaceInfo:(NSDictionary *)faceInfo{
    _faceInfo = faceInfo;
    //分析数据
    NSDictionary *rect = faceInfo[@"face_rectangle"];
    //裁剪出人脸
    CGFloat x = [rect[@"left"] floatValue];
    CGFloat y = [rect[@"top"] floatValue];
    CGFloat w = [rect[@"width"] floatValue];
    CGFloat h = [rect[@"height"] floatValue];
    self.icon.image = [self.fullImage cropWithRect:CGRectMake(x, y, w, h)];
    
    //获取属性
    NSDictionary *att = faceInfo[@"attributes"];
    NSMutableString *detailStr = [NSMutableString string];
    
    NSString *value = nil;
    value = att[@"gender"][@"value"];
    [detailStr appendFormat:@"性别: %@",value];
    BOOL isMan;
    if ([value isEqualToString:@"Male"]) {
        isMan = YES;
    }else{
        isMan = NO;
    }
    value = att[@"age"][@"value"];
    [detailStr appendFormat:@"\n年龄: %@",value];
    
//    value = [self largeKeyWith:att[@"smile"]];
//    NSString *score = att[@"smile"][@"value"];
//
//    if ([value isEqualToString:@"value"]) {
//        value = [NSString stringWithFormat:@"\n微笑分数: %.2f,是否微笑: 是",score.floatValue];
//    }else{
//        value = [NSString stringWithFormat:@"\n微笑分数: %.2f,是否微笑: 否",score.floatValue];
//    }
//    [detailStr appendFormat:@"\n%@",value];
    
    NSDictionary *emotionDic = att[@"emotion"];
    value = [self largeKeyWith:emotionDic];
    [detailStr appendFormat:@"\n表情: %@",value];
    
    value = att[@"ethnicity"][@"value"];
    [detailStr appendFormat:@"\n人种: %@",value];
    if (isMan) {
      value = att[@"beauty"][@"male_score"];
    }else{
      value = att[@"beauty"][@"female_score"];
    }
    
    [detailStr appendFormat:@"\n颜值评分: %.2lf",[value floatValue]];
    
//    [detailStr appendFormat:@"\n皮肤情况:"];
    NSMutableArray *skins = [NSMutableArray array];
    
    value = att[@"skinstatus"][@"health"];
    [skins addObject:@([value floatValue])];
   

    value = att[@"skinstatus"][@"stain"];
    [skins addObject:@([value floatValue])];

    value = att[@"skinstatus"][@"acne"];
    [skins addObject:@([value floatValue])];
//    [detailStr appendFormat:@"\n青春痘:%.2lf",[value floatValue]];
    value = att[@"skinstatus"][@"acne"];
    [skins addObject:@([value floatValue])];
//    [detailStr appendFormat:@"\n黑眼圈:%.2lf",[value floatValue]];
    NSNumber *max =  [skins valueForKeyPath:@"@max.floatValue"];
   
    for (int i = 0; i<skins.count; i++) {
        if ([max isEqualToNumber:skins[i]]) {
            
            switch (i) {
                case 0:
                        [detailStr appendFormat:@"\n皮肤情况:健康  概率:%.2lf%%",[skins[i] floatValue]];
                    break;
                case 1:
                        [detailStr appendFormat:@"\n皮肤情况:色斑  概率:%.2lf%%",[skins[i] floatValue]];
                    break;
                case 2:
                     [detailStr appendFormat:@"\n皮肤情况:青春痘  概率:%.2lf%%",[skins[i] floatValue]];
                    break;
                case 3:
                     [detailStr appendFormat:@"\n皮肤情况:黑眼圈  概率:%.2lf%%",[skins[i] floatValue]];
                    break;
                default:
                    break;
            }
            i =(int)skins.count ;
        }
    }
    
//    NSDictionary *temp = att[@"eyestatus"][@"left_eye_status"];
//    NSDictionary *eyeDic = @{@"occlusion" : @"眼睛被遮挡",
//                             @"no_glass_eye_open" : @"不戴眼镜且睁眼",
//                             @"normal_glass_eye_close" : @"佩戴普通眼镜且闭眼",
//                             @"normal_glass_eye_open" : @"佩戴普通眼镜且睁眼",
//                             @"dark_glasses" : @"佩戴墨镜",
//                             @"no_glass_eye_close" : @"不戴眼镜且闭眼"};
//    value = [self largeKeyWith:temp];
//    [detailStr appendFormat:@"\n左眼状态: %@",eyeDic[value]];
//
//    temp = att[@"eyestatus"][@"right_eye_status"];
//    value = [self largeKeyWith:temp];
//    [detailStr appendFormat:@"\n右眼状态: %@",eyeDic[value]];
//
//    temp = att[@"headpose"];
//    [detailStr appendFormat:@"\n抬头角度: %@",temp[@"pitch_angle"]];
//    [detailStr appendFormat:@"\n平面旋转角度: %@",temp[@"roll_angle"]];
//    [detailStr appendFormat:@"\n左右摇头角度: %@",temp[@"yaw_angle"]];
    
//    value = [self largeKeyWith:att[@"facequality"]];
//    score = att[@"facequality"][@"value"];
//    if ([value isEqualToString:@"value"]) {
//        value = [NSString stringWithFormat:@"人脸质量分数: %.2f, 可以用做人脸比对",score.floatValue];
//    }else{
//        value = [NSString stringWithFormat:@"人脸质量分数: %.2f, 不建议用做人脸比对",score.floatValue];
//    }
//    [detailStr appendFormat:@"\n%@",value];
    
    self.detail.attributedText = [[NSAttributedString alloc]initWithString:detailStr];
}

//取出value值最大的对应的key
- (NSString *)largeKeyWith:(NSDictionary *)dic{
    __block NSString *largeKey = nil;
    __block CGFloat maxValue = 0;
    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj floatValue] > maxValue) {
            maxValue = [obj floatValue];
            largeKey = key;
        }
    }];
    return largeKey;
}

- (void)layoutSubviews{
    [super layoutSubviews];
//    self.icon.frame = CGRectMake(0, 5, 50, 50);
//    self.detail.frame = CGRectMake(60, 5, self.bounds.size.width - 55 - 5, self.bounds.size.height - 10);
}

@end


@interface FCDetectViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>{
     UICollectionView *_collectionView;
}

@end

@implementation FCDetectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor =[UIColor colorWithHexString:@"0099ff" alpha:1.0f];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    CGFloat margin = 10.0f;
    CGFloat itemWidth = (self.view.bounds.size.width - 2*margin);
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0.f;
    layout.itemSize = CGSizeMake(itemWidth, self.view.bounds.size.height*0.6-2*margin-64);
    layout.sectionInset = UIEdgeInsetsMake(margin, margin, margin, margin);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height*0.4+64, self.view.bounds.size.width, self.view.bounds.size.height*0.6-64) collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.pagingEnabled = YES;
    _collectionView.bounces = YES;
    _collectionView.backgroundColor = [UIColor whiteColor];
   _collectionView.alwaysBounceHorizontal = YES;
[_collectionView registerNib:[UINib nibWithNibName:@"FaceCell" bundle:nil] forCellWithReuseIdentifier:@"FaceCell"];
    [self.view addSubview:_collectionView];
//    [self handleImage:self.image];
}



- (void)handleImage:(UIImage *)image{
    //清除人脸框
    [self.imageView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    //检测人脸
    FCPPFaceDetect *faceDetect = [[FCPPFaceDetect alloc] initWithImage:image];
//    self.imageView.image = faceDetect.image;
    self.image = faceDetect.image;
    
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //需要获取的属性
    NSArray *att = @[@"gender",@"age",@"headpose",@"smiling",@"blur",@"eyestatus",@"emotion",@"facequality",@"ethnicity",@"beauty",@"skinstatus"];
    [faceDetect detectFaceWithReturnLandmark:YES attributes:att completion:^(id info, NSError *error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
       
        [weakSelf.dataArray removeAllObjects];

        if (info) {
            NSArray *array = info[@"faces"];
            if (array.count) {
                UIImage *image = faceDetect.image;

                //绘制关键点和矩形框
                [weakSelf handleImage:image withInfo:array];
                
                //显示每个人脸的详细信息
                [weakSelf.dataArray addObjectsFromArray:array];
                //显示json
                [weakSelf showResult:info];
            }else{
                [weakSelf showContent:@"没有检测到人脸"];
            }
        }else{
            [weakSelf showError:error];
        }
        [_collectionView reloadData];
      
    }];
}

- (void)handleImage:(UIImage *)image withInfo:(NSArray *)array{
    
    CGFloat scaleH = self.imageView.bounds.size.width / image.size.width;
    CGFloat scaleV = self.imageView.bounds.size.height / image.size.height;
    CGFloat scale = scaleH < scaleV ? scaleH : scaleV;
    CGFloat offsetX = image.size.width*(scaleH - scale)*0.5;
    CGFloat offsetY = image.size.height*(scaleV - scale)*0.5;

    //绘制矩形框
    for (NSDictionary *dic in array) {
        NSDictionary *rect = dic[@"face_rectangle"];
        CGFloat angle = [dic[@"attributes"][@"headpose"][@"roll_angle"] floatValue];

        CGFloat x = [rect[@"left"] floatValue];
        CGFloat y = [rect[@"top"] floatValue];
        CGFloat w = [rect[@"width"] floatValue];
        CGFloat h = [rect[@"height"] floatValue];

        UIView *rectView = [[UIView alloc] initWithFrame:CGRectMake(x*scale+offsetX, y*scale+offsetY, w*scale, h*scale)];
        rectView.transform = CGAffineTransformMakeRotation(angle/360.0 *2*M_PI);
        rectView.layer.borderColor = [UIColor greenColor].CGColor;
        rectView.layer.borderWidth = 1;

        [self.imageView addSubview:rectView];
    }
//
//    //绘制关键点
    UIGraphicsBeginImageContext(image.size);
    [image drawAtPoint:CGPointZero];
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (NSDictionary *dic in array) {
        NSArray *dicArr = [dic[@"landmark"] allValues];
        for (NSDictionary *p in dicArr) {
            CGFloat x = [p[@"x"] floatValue];
            CGFloat y = [p[@"y"] floatValue];

            [[UIColor blueColor] set];
            CGContextAddArc(context, x, y, 1/scale, 0, 2*M_PI, 0);
            CGContextDrawPath(context, kCGPathFill);
        }
    }
    
    UIImage *temp = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.imageView.image = temp;
}


#pragma mark CollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"FaceCell";
    FaceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.fullImage = self.image;
    NSDictionary *dic = self.dataArray[indexPath.row];
    cell.faceInfo = dic;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    
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
