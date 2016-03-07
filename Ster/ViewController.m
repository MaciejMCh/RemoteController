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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.websocket;
    
    NSEvent * (^monitorHandler)(NSEvent *);
    monitorHandler = ^NSEvent * (NSEvent * theEvent){
        
        
        unsigned int down = theEvent.type == 10 ? 1 : 0;
        
        for (CFIndex i = 0; i < WebSocketGetClientCount(self.websocket); ++i) {
            WebSocketClientRef client = WebSocketGetClientAtIndex(self.websocket, i);
            WebSocketClientWriteWithFormat(client, CFSTR("%d %d"), down, [theEvent keyCode]);
        }
        return theEvent;
    };
    
    // Creates an object we do not own, but must keep track of so that
    // it can be "removed" when we're done; therefore, put it in an ivar.
    self.eventMon = [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask | NSKeyUpMask
                                                     handler:monitorHandler];
    
    
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

@end
