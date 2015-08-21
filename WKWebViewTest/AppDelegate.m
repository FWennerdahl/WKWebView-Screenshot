//
//  AppDelegate.m
//  WKWebViewTest
//
//  Created by Felix Deimel on 10.06.15.
//  Copyright © 2015 Lemon Mojo - Felix Deimel e.U. All rights reserved.
//

#import "AppDelegate.h"
#import <WebKit/WebKit.h>
#import "WKWebView+Screenshot.h"

@interface NSObject (Testing)

- (void)performSelector:(SEL)selector withBlockingCallback:(dispatch_block_t)block;

@end

@implementation NSObject (Testing)

- (void)performSelector:(SEL)selector withBlockingCallback:(dispatch_block_t)block
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [self performSelector:selector withObject:^{
        if (block) block();
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    dispatch_release(semaphore);
}

@end

@interface AppDelegate ()

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTabView *tabView;
@property (assign) IBOutlet NSImageView *imageView;

@end

@implementation AppDelegate {
    NSMutableArray *m_webViews;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    m_webViews = [[NSMutableArray alloc] init];
    [self.imageView registeredDraggedTypes];
    WKWebViewConfiguration* config = [[[WKWebViewConfiguration alloc] init] autorelease];
    WKPreferences* prefs = config.preferences;
    
    prefs.javaScriptEnabled = YES;
    prefs.javaEnabled = YES;
    prefs.javaScriptCanOpenWindowsAutomatically = YES;
    prefs.plugInsEnabled = YES;
    
    [m_webViews addObject:[self addWebViewWithConfig:config url:@"http://www.google.com/" toView:[self.tabView.tabViewItems[0] view]]];
    [m_webViews addObject:[self addWebViewWithConfig:config url:@"http://www.javatester.org/" toView:[self.tabView.tabViewItems[1] view]]];
    [m_webViews addObject:[self addWebViewWithConfig:config url:@"http://www.audiotool.com/app" toView:[self.tabView.tabViewItems[2] view]]];
    [m_webViews addObject:[self addWebViewWithConfig:config url:@"http://www.medicalrounds.com/quicktimecheck/troubleshooting.html" toView:[self.tabView.tabViewItems[3] view]]];
}

- (WKWebView*)addWebViewWithConfig:(WKWebViewConfiguration*)config url:(NSString*)url toView:(NSView*)view
{
    WKWebView* v = [[[WKWebView alloc] initWithFrame:view.bounds configuration:config] autorelease];
    v.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    
    [view addSubview:v];
    
    NSURLRequest* req = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [v loadRequest:req];
    
    return v;
}

- (IBAction)buttonCaptureScreenshot_action:(id)sender
{
    WKWebView* wkWebView = [m_webViews objectAtIndex:[self.tabView indexOfTabViewItem:self.tabView.selectedTabViewItem]];
    
    [self captureScreenshotAsyncInWKWebView:wkWebView];
}

- (void)captureScreenshotAsyncInWKWebView:(WKWebView*)wkWebView
{
    [wkWebView captureScreenshotWithCompletionHandler:^(NSImage *screenshot) {
        self.imageView.image = screenshot;
    }];
}

- (void)captureScreenshotSyncInWKWebView:(WKWebView*)wkWebView
{
    dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
    NSImage* screenshot = [wkWebView captureScreenshotWithTimeout:timeout];
    
    self.imageView.image = screenshot;
}

@end