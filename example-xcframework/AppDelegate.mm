#import <AppKit/AppKit.h>

#include "BoostTests.hpp"

#include <cstdio>
#include <cstdlib>

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property(nonatomic, strong) NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    (void)notification;

    BoostTestResult result = runBoostTests();
    NSString *report = [NSString stringWithUTF8String:result.report.c_str()];
    NSLog(@"\n%@", report);

    self.window = [[NSWindow alloc]
        initWithContentRect:NSMakeRect(0, 0, 760, 520)
                  styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable |
                            NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable
                    backing:NSBackingStoreBuffered
                      defer:NO];
    self.window.title = @"ofxOSXBoost tests";
    self.window.backgroundColor = result.passed
        ? [NSColor colorWithCalibratedRed:0.90 green:1.0 blue:0.92 alpha:1.0]
        : [NSColor colorWithCalibratedRed:1.0 green:0.90 blue:0.90 alpha:1.0];

    NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:self.window.contentView.bounds];
    scrollView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    scrollView.hasVerticalScroller = YES;
    NSTextView *textView = [[NSTextView alloc] initWithFrame:scrollView.bounds];
    textView.editable = NO;
    textView.font = [NSFont monospacedSystemFontOfSize:14.0 weight:NSFontWeightRegular];
    textView.string = report;
    scrollView.documentView = textView;
    self.window.contentView = scrollView;
    [self.window center];
    [self.window makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    (void)sender;
    return YES;
}

@end

int main(int argc, char *argv[])
{
    @autoreleasepool {
        if (std::getenv("OFXOSXBOOST_CI") != nullptr) {
            BoostTestResult result = runBoostTests();
            std::fprintf(stdout, "%s\n", result.report.c_str());
            return result.passed ? EXIT_SUCCESS : EXIT_FAILURE;
        }
        NSApplication *application = [NSApplication sharedApplication];
        AppDelegate *delegate = [[AppDelegate alloc] init];
        application.delegate = delegate;
        return NSApplicationMain(argc, (const char **)argv);
    }
}
