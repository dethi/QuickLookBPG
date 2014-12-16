//
//  BPGDecode.m
//  QuickLookBPG
//
//  Created by Thibault Deutsch on 16/12/14.
//  Copyright (c) 2014 Thibault Deutsch. All rights reserved.
//

#import "BPGDecode.h"
#import "libs/libbpg.h"

CGImageRef CreateImageForURL(CFURLRef url)
{
    NSData *fileData = [[NSData alloc] initWithContentsOfURL:(__bridge NSURL *)url];
    BPGDecoderContext *img;
    img = bpg_decoder_open();
    
    int buf_len = (int)fileData.length;
    uint8_t *buf = malloc(buf_len);
    
    /* Get BPG image data */
    if (bpg_decoder_decode(img, buf, buf_len) < 0) {
        NSLog(@"(bpg_decoder_decode) cannot get BPG image data for %@", url);
        free(buf);
        return NULL;
    }
    free(buf);
    
    BPGImageInfo img_info;
    bpg_decoder_get_info(img, &img_info);
    
    int w = img_info.width;
    int h = img_info.height;
    
    uint8_t *rgba_data = malloc(4 * w * h);
    
    /* Decode BPG image */
    bpg_decoder_start(img, BPG_OUTPUT_FORMAT_RGBA32);
    for (int y = 0; y < h; ++y)
        bpg_decoder_get_line(img, &rgba_data[y * w * 4]);
    
    bpg_decoder_close(img);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    CGContextRef bitmapContext = CGBitmapContextCreate(rgba_data, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedLast);
    CGImageRef cgImage = CGBitmapContextCreateImage(bitmapContext);
    
    CGColorSpaceRelease(colorSpace);
    free(rgba_data);
    return cgImage;
}
