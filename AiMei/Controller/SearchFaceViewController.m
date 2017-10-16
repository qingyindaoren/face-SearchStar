//
//  SearchFaceViewController.m
//  AiMei
//
//  Created by 美融城 on 2017/10/12.
//  Copyright © 2017年 美融城. All rights reserved.
//

#import "SearchFaceViewController.h"
#import "FCPPSDK.h"
#import "MBProgressHUD.h"
#import "SDImageCache.h"
#define faceFilePath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"face.plist"]
@interface SearchFaceViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *faceImage;
@property (weak, nonatomic) IBOutlet UIImageView *startImage;
@property (weak, nonatomic) IBOutlet UILabel *personName;
@property (strong , nonatomic) FCPPFaceSet *faceSet;

@property (strong , nonatomic) NSMutableDictionary *faceMap;



@property (assign , nonatomic) BOOL addFace;
@property (assign , nonatomic) NSInteger faceIndex;

@property (nonatomic,strong)NSArray *images;
@end

@implementation SearchFaceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.faceIndex = 0;
    //1.创建人脸集合
    NSString *outerId = @"StartFaceSet";//设置自定义标记
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"正在创建人脸集合...";
    [FCPPFaceSet createFaceSetWithDisplayName:@"人脸搜索" outerId:outerId tgas:nil faceTokens:nil userData:nil forceMerge:YES completion:^(id info, NSError *error) {
        if (error == nil) {
            hud.label.text = @"创建人脸集合完成";
            [hud hideAnimated:YES afterDelay:1.0];
            self.faceSet = [[FCPPFaceSet alloc] initWithOuterId:outerId];
        }else{
            hud.label.text = @"人脸集合创建失败,请重新进入";
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [hud hideAnimated:YES];
                [self.navigationController popViewControllerAnimated:YES];
            });
        }
    }];
    NSLog(@"%@",faceFilePath);
   
}
//选取图片
- (IBAction)selectImage:(UIButton *)sender {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:@"添加图片" preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;

    UIAlertAction *libAction = [UIAlertAction actionWithTitle:@"打开相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = weakSelf;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [weakSelf presentViewController:picker animated:YES completion:nil];
    }];
    [alertVC addAction:libAction];

    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"打开相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = weakSelf;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [weakSelf presentViewController:picker animated:YES completion:nil];
    }];
    [alertVC addAction:cameraAction];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

    }];
    [alertVC addAction:cancelAction];

    [self presentViewController:alertVC animated:YES completion:nil];
//刚拿到demo把这个方法里下面注释的放开，把上面的注掉
//    //创建明星集合 这个方法只调用一次  添加时打印出face.plist的路径，添加库完毕后，把储存好的那个face.plist移除来，替换左边images文件夹里的那个face.plist。然后把上面的打开，把下面的注掉。
//   NSDictionary *dataDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"imagelist" ofType:@"plist"]];
//    NSArray *images = [NSArray arrayWithArray:dataDict[@"starts"]];
//    self.images = images;
//    if (self.faceIndex<72) {
//        UIImage *image = [UIImage imageNamed:images[self.faceIndex]];
//
//        [self addImage: image];
//
//    }else{
//         MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        hud.label.text = @"完成";
//        [hud hideAnimated:YES afterDelay:1.5];
//    }

    
    
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [self handleImage:image];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)handleImage:(UIImage *)image{
    self.faceImage.image = image;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"正在搜索....";
    FCPPFace *face = [[FCPPFace alloc] initWithImage:image];
 
    //4.搜索
    [face searchFromFaceSet:self.faceSet returnCount:1 completion:^(id info, NSError *error) {
//
        if (info) {
            NSArray *faces = info[@"faces"];
            if (faces.count) {
               
                NSDictionary *result = [info[@"results"] firstObject];
                NSDictionary *thresholds = info[@"thresholds"];
                NSString *faceToken = result[@"face_token"];
                CGFloat confidence = [result[@"confidence"] floatValue];
//                CGFloat maxThreshold = [thresholds[@"1e-5"] floatValue];
//                CGFloat midThreshold = [thresholds[@"1e-4"] floatValue];
                CGFloat minThreshold = [thresholds[@"1e-2"] floatValue];
                
                BOOL vaild = confidence > minThreshold;//置信度大于阈值,才算搜到的是一个人
                if (faceToken && vaild) {//搜索到人脸
                    NSLog(@"%@",faceToken);
                       [hud hideAnimated:YES];
                  
                    //5.根据faceToken的映射关系,取出相应信息
               
                        NSDictionary *dict = self.faceMap[faceToken];
                        self.startImage.image = [UIImage imageNamed:dict[@"personName"]];
                      
                        self.personName.text =[NSString stringWithFormat:@"经过小数据智能分析，您与%@十分相似",dict[@"personName"]] ;
                        
                 
                }else{
                    hud.label.text = @"没有搜索到合适的人脸";
                    [hud hideAnimated:YES afterDelay:1.0];
                    self.startImage.image = nil;
                    self.personName.text = @"没有搜索到合适的人脸";
                }
            }else{
                hud.label.text = @"没有检测到人脸";
                [hud hideAnimated:YES afterDelay:1.0];
                self.startImage.image = nil;
                self.personName.text = @"没有检测到人脸";
            }
        }else{
            hud.label.text = @"网络请求失败";
            [hud hideAnimated:YES afterDelay:1.0];
            self.startImage.image = nil;
            self.personName.text = @"网络请求失败";
        }
    
    }];
    

   
}
//添加人脸集合
- (void)addImage:(UIImage *)image{

    __weak typeof(self) weakSelf = self;

    self.faceImage.image = image;

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"正在检测人脸...";
    //2.0检测人脸
    FCPPFaceDetect *faceDetector = [[FCPPFaceDetect alloc] initWithImage:image];
    [faceDetector detectFaceWithReturnLandmark:NO attributes:nil completion:^(id info, NSError *error) {
        if (error) {
            hud.label.text = @"人脸检测失败,请重新添加";
            [hud hideAnimated:YES afterDelay:1.5];
        }else{
            hud.label.text = @"正在添加到人脸集合...";
            NSArray *faceTokens = [info[@"faces"] valueForKeyPath:@"face_token"];

            //3.添加到人脸集合
            if (faceTokens.count && weakSelf.faceSet) {
                [weakSelf.faceSet addFaceTokens:faceTokens completion:^(id info, NSError *error) {
                    if (error == nil) {

                        //2.1建立映射关系
                        for (NSString *faceToken in faceTokens) {
                            //把图片存储到本地，faceToken作为key存储图片
//                            [[SDImageCache sharedImageCache] storeImage:image forKey:faceToken];
                            NSString *name = self.images[self.faceIndex];
                            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                            //赋值
//                            [dic setObject:faceToken forKey:@"imageKey"];
                            [dic setObject:name forKey:@"personName"];

  NSLog(@"%@",name);


                            [weakSelf.faceMap setObject:dic forKey:faceToken];//建立映射
//                            [weakSelf.dataArray addObject:faceToken];
                        }
                        if (![[NSFileManager defaultManager] fileExistsAtPath:faceFilePath isDirectory:NULL]) {
                        NSFileManager* fm = [NSFileManager defaultManager];
                        [fm createFileAtPath:faceFilePath contents:nil attributes:nil];
                        }
                       
                        [weakSelf.faceMap writeToFile:faceFilePath atomically:YES];


                        hud.label.text = @"添加成功";
                         self.faceIndex++;
                    }else{
                        hud.label.text = @"添加失败";
                    }
                    [hud hideAnimated:YES afterDelay:1.5];
                }];
            }else{
                hud.label.text = @"添加失败";
                [hud hideAnimated:YES afterDelay:1.5];
            }
        }
    }];
}


- (NSMutableDictionary *)faceMap{
    if (_faceMap == nil) {
        _faceMap = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"face" ofType:@"plist"]].mutableCopy;
    }
    
    if (_faceMap == nil) {
        _faceMap = [NSMutableDictionary dictionary];
    }
    return _faceMap;
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
