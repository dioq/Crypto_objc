#import "RSAUtil.h"
#import <Security/Security.h>
#import "CryptoUtil.h"

@implementation RSAUtil

+ (NSData *)encryptData:(NSData *)data publicKey:(NSData *)key {
    if (!(data && data.length > 0 && key && key.length > 0)) {
        return nil;
    }
    
    // 生成的证书头要去掉,中间的才是 RSA 公钥有效部分
    //        NSMutableData *mutData = [key mutableCopy];
    //        [mutData replaceBytesInRange:NSMakeRange(0, 22) withBytes:NULL length:0];
    //        NSData *stripData = [mutData copy];
    // 22 ,24
    NSData *stripData = [RSAUtil stripPublicKeyHeader:key];
    
    SecKeyRef keyRef = [RSAUtil getRSAkey:stripData keyClass:kSecAttrKeyClassPublic];
    if(!keyRef){
        return nil;
    }
    return [RSAUtil encryptData:data withKeyRef:keyRef];
}

+ (NSData *)decryptData:(NSData *)data privateKey:(NSData *)key {
    if (!(data && data.length > 0 && key && key.length > 0)) {
        return nil;
    }
    
    // 生成的证书头要去掉,中间的才是 RSA 公钥有效部分
    //    NSMutableData *mutData = [key mutableCopy];
    //    [mutData replaceBytesInRange:NSMakeRange(0, 26) withBytes:NULL length:0];
    //    NSData *stripData = [mutData copy];
    NSData *stripData = [RSAUtil stripPrivateKeyHeader:key];
    
    SecKeyRef keyRef = [RSAUtil getRSAkey:stripData keyClass:kSecAttrKeyClassPrivate];
    if(!keyRef){
        return nil;
    }
    return [RSAUtil decryptData:data withKeyRef:keyRef];
}

+(NSData *)stripPublicKeyHeader:(NSData *)d_key{
    // Skip ASN.1 public key header
    if (d_key == nil) return(nil);
    
    unsigned long len = [d_key length];
    if (!len) return(nil);
    
    unsigned char *c_key = (unsigned char *)[d_key bytes];
    unsigned int  idx     = 0;
    
    if (c_key[idx++] != 0x30) return(nil);
    
    if (c_key[idx] > 0x80) idx += c_key[idx] - 0x80 + 1;
    else idx++;
    
    // PKCS #1 rsaEncryption szOID_RSA_RSA
    static unsigned char seqiod[] =
    { 0x30,   0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01,
        0x01, 0x05, 0x00 };
    if (memcmp(&c_key[idx], seqiod, 15)) return(nil);
    
    idx += 15;
    
    if (c_key[idx++] != 0x03) return(nil);
    
    if (c_key[idx] > 0x80) idx += c_key[idx] - 0x80 + 1;
    else idx++;
    
    if (c_key[idx++] != '\0') return(nil);
    
    return ([NSData dataWithBytes:&c_key[idx] length:len - idx]);
}

+(NSData *)stripPrivateKeyHeader:(NSData *)d_key{
    // Skip ASN.1 private key header
    if (d_key == nil) return(nil);
    
    unsigned long len = [d_key length];
    if (!len) return(nil);
    
    unsigned char *c_key = (unsigned char *)[d_key bytes];
    unsigned int  idx     = 22; //magic byte at offset 22
    
    if (0x04 != c_key[idx++]) return nil;
    
    //calculate length of the key
    unsigned int c_len = c_key[idx++];
    int det = c_len & 0x80;
    if (!det) {
        c_len = c_len & 0x7f;
    } else {
        int byteCount = c_len & 0x7f;
        if (byteCount + idx > len) {
            //rsa length field longer than buffer
            return nil;
        }
        unsigned int accum = 0;
        unsigned char *ptr = &c_key[idx];
        idx += byteCount;
        while (byteCount) {
            accum = (accum << 8) + *ptr;
            ptr++;
            byteCount--;
        }
        c_len = accum;
    }
    
    return [d_key subdataWithRange:NSMakeRange(idx, c_len)];
}

+(SecKeyRef)getRSAkey:(NSData *)key keyClass:(CFStringRef)keyClassRef {
    CFStringRef keys[] = {kSecAttrKeyType, kSecAttrKeyClass};//, kSecAttrKeySizeInBits};
    CFTypeRef values[] = {kSecAttrKeyTypeRSA, keyClassRef};//, CFSTR("2048")};
    
    CFDictionaryRef dict = CFDictionaryCreate(CFAllocatorGetDefault(), (const void **)keys, (const void **)values, 2, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    //    NSLog(@"dict:\n%@",dict);
    NSLog(@"%d key:\n%@\nlength:0x%lx",__LINE__,[CryptoUtil hexEncode:key],[key length]);
//    NSDictionary *nsDict = (__bridge NSDictionary *)dict;
//    NSString *keyClass = [nsDict valueForKey:(__bridge NSString *)kSecAttrKeyClass];
//    NSLog(@"%d keyClass:%@",__LINE__,keyClass);
//    if ([keyClass isEqual:@"0"]) {
//        
//    }else if([keyClass isEqual:@"1"]) {
//        
//    }
    CFErrorRef errorRef = NULL;
    SecKeyRef ret = SecKeyCreateWithData((__bridge CFDataRef)key, dict, &errorRef);
    if (errorRef != NULL) {
        NSError *error = (__bridge_transfer NSError *)errorRef;
        NSLog(@"error NO:%ld des:%@", error.code, [error localizedDescription]);
    }
    return ret;
}

+ (NSData *)encryptData:(NSData *)data withKeyRef:(SecKeyRef) keyRef{
    const uint8_t *srcbuf = (const uint8_t *)[data bytes];
    size_t srclen = (size_t)data.length;
    
    size_t block_size = SecKeyGetBlockSize(keyRef) * sizeof(uint8_t);
    void *outbuf = malloc(block_size);
    size_t src_block_size = block_size - 11;
    
    NSMutableData *ret = [[NSMutableData alloc] init];
    for(int idx=0; idx<srclen; idx+=src_block_size){
        size_t data_len = srclen - idx;
        if(data_len > src_block_size){
            data_len = src_block_size;
        }
        
        size_t outlen = block_size;
        OSStatus status = noErr;
        status = SecKeyEncrypt(keyRef,
                               kSecPaddingPKCS1,
                               srcbuf + idx,
                               data_len,
                               outbuf,
                               &outlen
                               );
        if (status != 0) {
            NSLog(@"SecKeyEncrypt fail. Error Code: %d", status);
            ret = nil;
            break;
        }else{
            [ret appendBytes:outbuf length:outlen];
        }
    }
    
    free(outbuf);
    CFRelease(keyRef);
    return ret;
}

+ (NSData *)decryptData:(NSData *)data withKeyRef:(SecKeyRef) keyRef{
    const uint8_t *srcbuf = (const uint8_t *)[data bytes];
    size_t srclen = (size_t)data.length;
    
    size_t block_size = SecKeyGetBlockSize(keyRef) * sizeof(uint8_t);
    UInt8 *outbuf = malloc(block_size);
    size_t src_block_size = block_size;
    
    NSMutableData *ret = [[NSMutableData alloc] init];
    for(int idx=0; idx<srclen; idx+=src_block_size){
        size_t data_len = srclen - idx;
        if(data_len > src_block_size){
            data_len = src_block_size;
        }
        
        size_t outlen = block_size;
        OSStatus status = noErr;
        status = SecKeyDecrypt(keyRef,
                               kSecPaddingNone,
                               srcbuf + idx,
                               data_len,
                               outbuf,
                               &outlen
                               );
        if (status != 0) {
            NSLog(@"SecKeyEncrypt fail. Error Code: %d", status);
            ret = nil;
            break;
        }else{
            int idxFirstZero = -1;
            int idxNextZero = (int)outlen;
            for ( int i = 0; i < outlen; i++ ) {
                if ( outbuf[i] == 0 ) {
                    if ( idxFirstZero < 0 ) {
                        idxFirstZero = i;
                    } else {
                        idxNextZero = i;
                        break;
                    }
                }
            }
            
            [ret appendBytes:&outbuf[idxFirstZero+1] length:idxNextZero-idxFirstZero-1];
        }
    }
    
    free(outbuf);
    CFRelease(keyRef);
    return ret;
}

@end
