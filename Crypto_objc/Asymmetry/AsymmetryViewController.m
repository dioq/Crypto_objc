//
//  AsymmetryViewController.m
//  Crypto_objc
//
//  Created by zd on 22/3/2024.
//

#import "AsymmetryViewController.h"
#import "CryptoUtil.h"
#import "RSAUtil.h"

@interface AsymmetryViewController ()

@property(nonatomic, copy)NSString *publickKey;//公钥
@property(nonatomic, copy)NSString *privateKey;//私钥
@property(nonatomic, strong)NSData *cipherData;

@end

@implementation AsymmetryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"非对称加密";
    
    /*
     openssl 生成公钥和私钥
     openssl genrsa -out private_key.pem 2048
     openssl rsa -in private_key.pem -pubout -out public_key.pem
     **/
    //    self.publickKey = @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDaCXgeHqPXkv8qCpWFxpHteDn8j0GExQMHowbMzCbdhfysuFkl1DdbsTGT3QPOenlro5D7pn5onZ2doE/5nyMIyPBQ2Dhq/RSsQQQDofTBvA37PaT3rGa4e1Nn1fp5wcBh8RDwT7h2iYg6ndRe02A1bCxDW93OPGaWokSHs+0OUQIDAQAB";
    //    self.privateKey = @"MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBANoJeB4eo9eS/yoKlYXGke14OfyPQYTFAwejBszMJt2F/Ky4WSXUN1uxMZPdA856eWujkPumfmidnZ2gT/mfIwjI8FDYOGr9FKxBBAOh9MG8Dfs9pPesZrh7U2fV+nnBwGHxEPBPuHaJiDqd1F7TYDVsLENb3c48ZpaiRIez7Q5RAgMBAAECgYBHRP0ca0uG9aeuaFNDrQqaIshhg7oY2gUJhAJ/AuRZWKilFIUfVmTZ9euMt5u87E+wHYEQoPWE4LBai8JYh+n9JDJNdNokqLzVT7WStKbPuNETWYYa2WLf0vsU0LZUe2Wkvdl4UbgjfO2Br6Zvooqz1ot7XLlwrwrqSb1nullDIQJBAP+oQKxN3dh+2MjinsG6G2SaToc4IRcI5+lK4tOVJrH81qhRGWGIUVn25/UDCzROAdEn2o7lrlvgXDEgMKRb3q0CQQDaVE3w4uiyIYx6UZjC9OEYCKtd84/R1qRbH2UavKSpZVN1UlMgwaNYPBX2OwABUpv9HRmRR5nulSyYfHG8pNa1AkEA5jgVRRQ5miNgBEZOwBVfZZCu9oVNBvk2HZcZ+35sggs1Ig0l1fZzi5gT+UbsaAV3DWneHqAmCwZW/sYGB3vTYQJBAMbJkbmtcH+YCkbo+nUv768pXZaKiD1f+H+7Qxwn/Kj7yBR/Y47koCxbcQejyqppo/u/PiNIFUDk9BjW3dwMHi0CQGYGZILNBkKfJQwHK7ARFYhCFT5hzVUgTcE9RsMzFOToEyA9nNq4WgpHwA+QT7jnSQfqhMmXF+wleZfzfsQ4Gn0=";
    
    self.publickKey = @"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAoeMASyMmEy3KtpJ197lKnE+Mgo7WuK3i0H1vwf8y4WOmgXCJe9R5l0+ajpNDeL5nMdRfpuMu69VEaNX40fZXe2N8pnMvyTXurzScZ7IfH1XiRdLKT2ZiP6mFUQlZGZ96z0b2l4HXXxTxxkuZLObwfOalh4wLrAdmw0jTcPCZWJ2SujNJO6gDh/vw6KNeRO73c0IVLUBBAvZUKAPqq51PG0wvD4wCYl5JdfBsy5D+25fRMOE9y20V5tzIpemMGN3KmYLr+/dp4jrNdXA06RS2YumlMrASJCnjUaNuZRfqcZ3/vN4vUAjwl01hZ5X0xlHinC/fr7fOYJhmgAUSq2wa2QIDAQAB";
    self.privateKey = @"MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCh4wBLIyYTLcq2knX3uUqcT4yCjta4reLQfW/B/zLhY6aBcIl71HmXT5qOk0N4vmcx1F+m4y7r1URo1fjR9ld7Y3ymcy/JNe6vNJxnsh8fVeJF0spPZmI/qYVRCVkZn3rPRvaXgddfFPHGS5ks5vB85qWHjAusB2bDSNNw8JlYnZK6M0k7qAOH+/Doo15E7vdzQhUtQEEC9lQoA+qrnU8bTC8PjAJiXkl18GzLkP7bl9Ew4T3LbRXm3Mil6YwY3cqZguv792niOs11cDTpFLZi6aUysBIkKeNRo25lF+pxnf+83i9QCPCXTWFnlfTGUeKcL9+vt85gmGaABRKrbBrZAgMBAAECggEAI1tKQZ7UHoU2TGixhiC8aGZBWHRs9hnYO1PiGDst+CcFAyk6hcaSpdb3eSM1rcXcEPiCyZa9tTk3fzQYa3cDhUnlvA7VRXtXfYGelVFEVdoymLBgijXgyGm0Wc4SXTPFJUco7U8o5DXVVktFkZaAuK7BQVj3ZaOaMJWTxItv2nf62jAMV9uNvI4g4OXi3oGuYML4RaPbvGiCkLZJ3l/+kZQnV0dUszU09GMoMiGtPIxdtMhd4V/E7HZJfZnZ+nx47gdDI+KHVlVrsNmj6OSPREkrgm1IbIwoSs/CiOg35AhZjqN2QoVYWjwY8tZFH5Bllw42kpAlTxVv7TpMLsD8LwKBgQDM6xAOv1HpUcamjyYhk7LI0W++iqwbTscwbdI5YCWARRyiWeif56eIjnx9Rg9XvnxMRtJZUh1F6rCqOVSU+Muhp5+agU8Ktv2c41pFQYqe4cJbI9ALurGcauY5b0wPQkhAyyqgXbqbcRxLstYR/KKQCjUqQjdeSArG6+fhMaJLnwKBgQDKPd3jDjXBWycJf0/Lf6ycVQQsymggAvbPgHssKc0xZpiOH6igHHFNZlQdyQ+p6ut1Av0lvdz1DErGYt02Ez+Esi1p6F8cJYLaKY7/G0+atEnWluVW8XVmemzg0PB2PsZHLQ/kgnoQcRP5K96/Xn+X1OHq4bdGtuCunflFvR+GhwKBgDGr8RKCEcrqxapuHKIa+UVwbxPS7XEZIXN9y22Y/r4fApfgD2Fjd9rEHy0GpIVyaRLcP/Ti0LG39+brSrNps4KV7Tw4h/5i6Qr0mVccUgu9Ua1h+vY85PyzdOcLMXapbHY4STbiQW+YdXFsAjQN9yHPN5/suRsjf2lEmcqei2alAoGBAJhndM2FSNcUBN/wU8aLyRzqKEJEqaDt+uY18Rw/yAShRvdbPiyiInPsWBk2ChrHEHbWMMR/RoJXqAXGPONiL+ykhPqZhQrl7azPwpXWE/AGStpuThdt0EXQnjnw2jSRa8P5Xk+aT7gSLrYH7E0UPlzBrRnezMl6SOjt3QpD0f0DAoGAflFFKA4tfIcLtFBYeDm1P+6B+n0hNS769IpeUfplYSFKoGNbSTEvicgFe/65kWLn94VIZ9g1acriCRJToW83+0U4C7UkOsKtUv/onVaj32HZA6L8fEcVKWBPiADnR+KjLkkc6lAc3T99a95ibdLhqlGGQLplzl8zmqLIieT1vNo=";
}

- (IBAction)rsa_encrypt_act:(UIButton *)sender {
    NSString *plaintext = @"This is a test string for RSA encrypt.";
    
    self.cipherData = [RSAUtil encryptData:[plaintext dataUsingEncoding:NSUTF8StringEncoding] publicKey:[CryptoUtil base64Decode:self.publickKey]];
    //    NSString *ciphertext = [CryptoUtil hexEncode:cipher_data];
    NSString *ciphertext = [CryptoUtil base64Encode:self.cipherData];
    NSLog(@"cipher:\n%@", ciphertext);
}

- (IBAction)rsa_decrypt_act:(UIButton *)sender {
    NSData *plaint_data = [RSAUtil decryptData:self.cipherData privateKey:[CryptoUtil base64Decode:self.privateKey]];
    //    NSLog(@"plaint_data.length:%lu", plaint_data.length);
    NSString *plaintext2 = [[NSString alloc] initWithData:plaint_data encoding:NSUTF8StringEncoding];
    NSLog(@"plaintext:\n%@", plaintext2);
}

@end
