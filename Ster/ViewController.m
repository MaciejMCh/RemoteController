//
//  ViewController.m
//  Ster
//
//  Created by Maciej Chmielewski on 06.03.2016.
//  Copyright © 2016 Maciej Chmielewski. All rights reserved.
//

#import "ViewController.h"
#import <CoreWebSocket/CoreWebSocket.h>

@interface ViewController ()

@property (nonatomic, assign) CGPoint beginPoint;
@property (nonatomic, assign) CGPoint totalPoint;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *pressedButtons;
@property (nonatomic, strong) IBOutlet NSTextField *feedBackLabel;
@property (nonatomic, strong) IBOutlet NSTextField *mouseFeedBackLabel;
@property (nonatomic, strong) NSEvent *eventMon;
@property (nonatomic, assign) WebSocketRef websocket;

@end

@implementation ViewController

- (WebSocketRef)websocket {
    if (!_websocket) {
        _websocket = WebSocketCreateWithHostAndPort(NULL, kWebSocketHostAny, 6001, NULL);
    }
    return _websocket;
}

- (NSMutableArray *)pressedButtons {
    if (!_pressedButtons) {
        _pressedButtons = [NSMutableArray new];
    }
    return _pressedButtons;
}

- (void)downButton:(NSInteger)button {
    if ([self.pressedButtons containsObject:@(button)]) {
        return;
    }
    [self sendDown:button];
    [self.pressedButtons addObject:@(button)];
    [self refreshFeedBack];
}

- (void)upButton:(NSInteger)button {
    if (![self.pressedButtons containsObject:@(button)]) {
        return;
    }
    [self sendUp:button];
    [self.pressedButtons removeObject:@(button)];
    [self refreshFeedBack];
}

- (void)refreshFeedBack {
    NSMutableString *feedBackString = [NSMutableString new];
    for (NSNumber *pressedButton in self.pressedButtons) {
        [feedBackString appendFormat:@"%@ ", pressedButton];
    }
    self.feedBackLabel.stringValue = feedBackString;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.websocket;
    
    NSEvent * (^monitorHandler)(NSEvent *);
    monitorHandler = ^NSEvent * (NSEvent * theEvent){
        unsigned int down = theEvent.type == 10 ? 1 : 0;
        if (down) {
            [self downButton:[theEvent keyCode]];
        } else {
            [self upButton:[theEvent keyCode]];
        }
        return theEvent;
    };
    self.eventMon = [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask | NSKeyUpMask
                                                     handler:monitorHandler];
    
    [self.view addGestureRecognizer:[[NSPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)]];
}

- (void)handlePanGesture:(NSPanGestureRecognizer *)panGesture {
    CGPoint location = [panGesture locationInView:self.view];
    switch (panGesture.state) {
        case NSGestureRecognizerStateBegan:
            self.beginPoint = location;
            break;
        case NSGestureRecognizerStateChanged: {
            CGPoint currentPoint = CGPointMake(self.totalPoint.x + (location.x - self.beginPoint.x), self.totalPoint.y + (location.y - self.beginPoint.y));
            [self sendPanProgress:currentPoint];
            
            
            
            CGFloat tolerance = [self toleranceRadius];
            
            CGPoint midPoint = [self midPoint];
            CGRect toleranceRect = CGRectMake(midPoint.x - tolerance,
                                              midPoint.y - tolerance,
                                              tolerance * 2,
                                              tolerance * 2);
            location = [self absolutePoint:location];
            
            if (!CGRectContainsPoint(toleranceRect, location)) {
                CGPoint fix = CGPointMake(location.x - midPoint.x, location.y - midPoint.y);
                self.totalPoint = CGPointMake(self.totalPoint.x + fix.x, self.totalPoint.y - fix.y);
                [self moveMouseToPoint:midPoint];
            }
            break;
        }
        case NSGestureRecognizerStateEnded: {
            self.totalPoint = CGPointMake(self.totalPoint.x + (location.x - self.beginPoint.x), self.totalPoint.y + (location.y - self.beginPoint.y));
            break;
        }
        default:
            break;
    }
}

- (CGFloat)toleranceRadius {
    return 100;
}

- (CGPoint)absolutePoint:(CGPoint)point {
    CGPoint absoluteMid = [self midPoint];
    CGPoint localMid = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMidY(self.view.frame));
    return CGPointMake(point.x + (absoluteMid.x - localMid.x), CGRectGetHeight(self.view.frame) + (absoluteMid.y - localMid.y) - point.y);
}

- (CGPoint)midPoint {
    NSRect frameRelativeToWindow = [self.view convertRect:self.view.bounds toView:nil];
    NSRect frameRelativeToScreen = [self.view.window convertRectToScreen:frameRelativeToWindow];
    CGFloat neg = CGRectGetHeight([NSScreen mainScreen].frame);
    return CGPointMake(CGRectGetMidX(frameRelativeToScreen), neg - CGRectGetMidY(frameRelativeToScreen));
}

- (void)moveMouseToPoint:(CGPoint)point {
    CGEventRef move = CGEventCreateMouseEvent(NULL, kCGEventMouseMoved, point, kCGMouseButtonLeft);
    CGEventPost(kCGHIDEventTap, move);
}

- (void)sendPanProgress:(NSPoint)panProgress {
    self.mouseFeedBackLabel.stringValue = [NSString stringWithFormat:@"%.2f %.2f", panProgress.x, panProgress.y];
    [self send:(__bridge CFStringRef)([NSString stringWithFormat:@"m %.2f %.2f", panProgress.x, panProgress.y])];
}
                                    
- (void)sendDown:(NSInteger)key {
    [self send:(__bridge CFStringRef)([NSString stringWithFormat:@"d %ld", (long)key])];
}

- (void)sendUp:(NSInteger)key {
    [self send:(__bridge CFStringRef)([NSString stringWithFormat:@"u %ld", (long)key])];
}

- (void)send:(CFStringRef)data {
    for (CFIndex i = 0; i < WebSocketGetClientCount(self.websocket); ++i) {
        WebSocketClientRef client = WebSocketGetClientAtIndex(self.websocket, i);
        WebSocketClientWriteWithFormat(client, data);
    }
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

@end
