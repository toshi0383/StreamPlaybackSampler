//
//  ResourceLoaderController.m
//  HLSTest
//
//  Created by toshi0383 on 7/26/16.
//  Copyright © 2016 toshi0383. All rights reserved.
//

#import "ResourceLoaderController.h"

@implementation ResourceLoaderController

#pragma mark - AVAssetResourceLoaderDelegate
-(BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest
{

    NSLog(@"%s", __FUNCTION__);
    NSURL *url = loadingRequest.request.URL;
    NSLog(@"URL:%@", url);

    // Comments from the Class Reference
    // When the resource loading delegate, which implements the AVAssetResourceLoaderDelegate protocol, receives an instance of AVAssetResourceLoadingRequest as the second parameter of the delegate’s resourceLoader:shouldWaitForLoadingOfRequestedResource: method, it has the option of accepting responsibility for loading the referenced resource. If it accepts that responsibility, by returning YES, it must check whether the dataRequest property of the AVAssetResourceLoadingRequest instance is not nil.
    AVAssetResourceLoadingDataRequest *dataRequest = loadingRequest.dataRequest;
    if (dataRequest == nil) {
        return NO;
    }
    if ([url.scheme isEqualToString:@"hello"]) {
        if ([url.pathExtension isEqualToString:@"m3u8"]) {
            __block ResourceLoaderController *blockSelf = self;
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [blockSelf helloRequest: url loadingRequest: loadingRequest];
            });
        }
        else if ([url.pathExtension isEqualToString:@"ts"]) {
            __block ResourceLoaderController *blockSelf = self;
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [blockSelf helloRequest: url loadingRequest: loadingRequest];
            });
        }
        else {
            return NO;
        }
    }
    // If it is not nil, the resource loading delegate is informed of the range of bytes within the resource that are required by the underlying media system.
    long long currentOffset   = dataRequest.currentOffset;
    long long requestedOffset = dataRequest.requestedOffset;
    NSInteger requestedLength = dataRequest.requestedLength;
    NSLog(@"currentOffset:%lld", currentOffset);
    NSLog(@"requestedOffset:%lld", requestedOffset);
    NSLog(@"requestedLength:%ld", (long)requestedLength);

    // In response, the data is provided by one or more invocations of respondWithData: as required to provide the requested data. The data can be provided in increments determined by the resource loading delegate according to convenience or efficiency.
    //[dataRequest respondWithData:data];

    //[loadingRequest finishLoading];

    return YES;
}

-(BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForRenewalOfRequestedResource:(AVAssetResourceRenewalRequest *)renewalRequest
{
    NSLog(@"%s", __FUNCTION__);
    return YES;
}

-(void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest
{
    NSLog(@"%s", __FUNCTION__);
}

- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForResponseToAuthenticationChallenge:(NSURLAuthenticationChallenge *)authenticationChallenge
{
    NSLog(@"%s", __FUNCTION__);
    return YES;
}

-(void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)authenticationChallenge
{
    NSLog(@"%s", __FUNCTION__);
}

#pragma mark - Utilities

- (void)helloRequest: (NSURL*)url loadingRequest:(AVAssetResourceLoadingRequest*)loadingRequest {
    NSString *str = [url.absoluteString stringByReplacingOccurrencesOfString:@"hello" withString:@"http"];
    NSURL *newurl = [NSURL URLWithString: str];
    [[[NSURLSession sharedSession] dataTaskWithURL:newurl completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [loadingRequest.dataRequest respondWithData:data];

        // 以下、あってもなくても結果同じ
        NSLog(@"data.length:%lu", (unsigned long)data.length);
        NSHTTPURLResponse *httpres = (NSHTTPURLResponse *)response;
        NSLog(@"httpres.expectedContentLength:%lld", httpres.expectedContentLength);
        AVAssetResourceLoadingContentInformationRequest *contentInfoRequest = loadingRequest.contentInformationRequest;
        contentInfoRequest.contentType = httpres.allHeaderFields[@"Content-Type"];
        contentInfoRequest.contentLength = httpres.expectedContentLength;
        contentInfoRequest.byteRangeAccessSupported = YES;
        [loadingRequest finishLoading];
    }] resume];
}
@end
