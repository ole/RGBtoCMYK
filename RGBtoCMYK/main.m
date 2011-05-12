//
//  main.m
//  RGBtoCMYK
//
//  Created by Ole Begemann in May 2011.
//  Copyright 2011 Ole Begemann.
//  License: MIT License
//

#import <Cocoa/Cocoa.h>

NSBitmapImageRep *convertImageFileToCMYK(NSString *sourceFilename)
{
    NSImage *sourceImage = [[[NSImage alloc] initWithContentsOfFile:sourceFilename] autorelease];
    NSBitmapImageRep *sourceImageRep = [[sourceImage representations] objectAtIndex:0];
    
    NSColorSpace *targetColorSpace = [NSColorSpace genericCMYKColorSpace];
    NSBitmapImageRep *targetImageRep = [sourceImageRep bitmapImageRepByConvertingToColorSpace:targetColorSpace 
        renderingIntent: NSColorRenderingIntentPerceptual];
    return targetImageRep;
}


BOOL writeBitmapImageRepToFile(NSBitmapImageRep *imageRep, NSString *targetFilename)
{
    NSData *tiffData = [imageRep TIFFRepresentation];
    return [tiffData writeToFile:targetFilename atomically:NO];
}


int main (int argc, const char * argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    NSMutableArray *commandLineArguments = [NSMutableArray arrayWithArray:[[NSProcessInfo processInfo] arguments]];
    [commandLineArguments removeObjectAtIndex:0]; // first object is the name of the executable
    
    [commandLineArguments enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id filename, NSUInteger idx, BOOL *stop) {
        NSAutoreleasePool *loopPool = [[NSAutoreleasePool alloc] init];

        NSBitmapImageRep *cmykImageRep = convertImageFileToCMYK(filename);
        BOOL success = NO;
        if (cmykImageRep != nil) {
            NSString *baseFilename = [filename stringByDeletingPathExtension];
            NSString *targetFilename = [[baseFilename stringByAppendingString:@"-CMYK"] stringByAppendingPathExtension:@"tiff"];
            success = writeBitmapImageRepToFile(cmykImageRep, targetFilename);
        }
        
        if (success) {
            fprintf(stdout, "Success: %s\n", [filename UTF8String]);
        } else {
            fprintf(stderr, "Failure: %s\n", [filename UTF8String]);
        }
        
        [loopPool drain];
    }];
    
    [pool drain];
    return 0;
}
