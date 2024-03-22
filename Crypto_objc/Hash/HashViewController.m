//
//  HashViewController.m
//  Crypto_objc
//
//  Created by zd on 22/3/2024.
//

#import "HashViewController.h"
#import "CryptoUtil.h"

@interface HashViewController ()

@end

@implementation HashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Hash 散列";
}

- (IBAction)md5_act:(UIButton *)sender {
    NSString *plaintext = @"Hello Dio Brand";
    NSString *result = [CryptoUtil md5:plaintext];
    NSLog(@"MD5: %@", result);
}

- (IBAction)sha_act:(UIButton *)sender {
    NSString *plaintext = @"Hello Dio Brand";
    NSString *result = [CryptoUtil sha256:plaintext];
    NSLog(@"SHA256: %@", result);
}

@end
