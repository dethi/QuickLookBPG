#import <CoreFoundation/CoreFoundation.h>
#import <CoreServices/CoreServices.h>
#import <QuickLook/QuickLook.h>
#import "BPGDecode.h"

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options);
void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview);

/* -----------------------------------------------------------------------------
   Generate a preview for file

   This function's job is to create preview for designated file
   ----------------------------------------------------------------------------- */

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{
    CGImageRef image = CreateImageForURL(url);
    if (image == NULL)
        return -1;
    
    CGFloat width = CGImageGetWidth(image);
    CGFloat height = CGImageGetHeight(image);
    
    @autoreleasepool {
        NSDictionary *newOpt = [NSDictionary  dictionaryWithObjectsAndKeys:(NSString *)[(__bridge NSDictionary *)options objectForKey:(NSString *)kQLPreviewPropertyDisplayNameKey], kQLPreviewPropertyDisplayNameKey, [NSNumber numberWithFloat:width], kQLPreviewPropertyWidthKey, [NSNumber numberWithFloat:height], kQLPreviewPropertyHeightKey, nil];
        CGContextRef ctx = QLPreviewRequestCreateContext(preview, CGSizeMake(width, height), YES, (__bridge CFDictionaryRef)newOpt);
        CGContextDrawImage(ctx, CGRectMake(0,0,width,height), image);
        QLPreviewRequestFlushContext(preview, ctx);
        CGImageRelease(image);
        CGContextRelease(ctx);
    }
    
    return noErr;
}

void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview)
{
    // Implement only if supported
}
