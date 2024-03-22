//
//  SymmetryViewController.m
//  Crypto_objc
//
//  Created by zd on 22/3/2024.
//

#import "SymmetryViewController.h"
#import "AESUtil.h"

@interface SymmetryViewController ()
{
    NSString *key;
    NSString *iv;
}

@property(nonatomic, strong)NSData *cipherData;

@end

@implementation SymmetryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"对称加密";
    
    key = @"by78elrbovb3rncvk9kkwx0byxb70rlo";
    iv = @"ixJ7U9asz9GgGfk7";
}

- (IBAction)aes_encrypt_act:(UIButton *)sender {
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *plainText = @"user=test2&pwd=123456&code=quis&ip=127.0.0.1";
    NSData *plainData = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    
    self.cipherData = [AESUtil encryptData:plainData withKey:keyData iv:iv];
    
    NSString *ciphertext = [self.cipherData base64EncodedStringWithOptions:0];
    NSLog(@"加密后的密文:%@",ciphertext);
}

- (IBAction)aes_decrypt_act:(UIButton *)sender {
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [AESUtil decryptData:self.cipherData withKey:keyData iv:iv];
    NSString *plaintext = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"解密后的明文:%@",plaintext);
}

@end
