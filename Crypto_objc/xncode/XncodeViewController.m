//
//  XncodeViewController.m
//  Crypto_objc
//
//  Created by zd on 22/3/2024.
//

#import "XncodeViewController.h"
#import "CryptoUtil.h"

@interface XncodeViewController ()

@property(nonatomic, strong)NSString *tmpStr;
@property(nonatomic, strong)NSData *tmpData;

@end

@implementation XncodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"编码与解码";
}

- (IBAction)base64_encode_act:(UIButton *)sender {
    NSString *plainText = @"user=test1&pwd=111333&code=kxgi&ip=127.0.0.1";
    NSData *data = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    
    self.tmpStr = [CryptoUtil base64Encode:data];
    NSLog(@"base64 encode:%@",self.tmpStr);
}

- (IBAction)base64_decode_act:(UIButton *)sender {
    NSData *data = [CryptoUtil base64Decode:self.tmpStr];
    
    NSString *plainText = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"base64 decode:%@",plainText);
}

- (IBAction)hex_encode_act:(UIButton *)sender {
    NSString *plainText = @"user=test1&pwd=111333&code=kxgi&ip=127.0.0.1";
    NSData *data = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    
    self.tmpStr = [CryptoUtil hexEncode:data];
    NSLog(@"hex encode:%@",self.tmpStr);
}

- (IBAction)hex_decode_act:(UIButton *)sender {
    NSData *data = [CryptoUtil hexDecode:self.tmpStr];
    
    NSString *plainText = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"hex decode:%@", plainText);
}

@end
