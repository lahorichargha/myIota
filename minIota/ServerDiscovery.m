//
//  ServerDiscovery.m
//  iotaPad6
//
//  Created by Martin on 2011-04-21.
//  Copyright © 2011, MITM AB, Sweden
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  1.  Redistributions of source code must retain the above copyright
//      notice, this list of conditions and the following disclaimer.
//
//  2.  Redistributions in binary form must reproduce the above copyright
//      notice, this list of conditions and the following disclaimer in the
//      documentation and/or other materials provided with the distribution.
//
//  3.  Neither the name of MITM AB nor the name iotaMed®, nor the
//      names of its contributors may be used to endorse or promote products
//      derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY MITM AB ‘’AS IS’’ AND ANY
//  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL MITM AB BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  ServerDiscovery is self-retained. The reason for this is that one single instance
//  can serve a number of HTTP related modules wanting to find the servers. It can't
//  be based on pure class level methods, since it needs to implement the NSServiceDelegate
//  functions. For the same reason (being shared), it uses notifications instead of a
//  delegate protocol to update its clients.

#import "ServerDiscovery.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import "Notifications.h"

// -----------------------------------------------------------
#pragma mark -
#pragma mark Local declarations
// -----------------------------------------------------------

@interface ServerDiscovery ()

@property (nonatomic, retain) NSNetService *netService;
@property (nonatomic, assign) BOOL resolveDone;

- (void)forcedResolveWithWait;

@end


@implementation ServerDiscovery

@synthesize netService = _netService;
@synthesize resolveDone = _resolveDone;

static NSMutableArray *listOfIPs = nil;

// -----------------------------------------------------------
#pragma mark -
#pragma mark Public methods
// -----------------------------------------------------------

+ (NSArray *)getListOfIPsWithForcedResolve:(BOOL)forceResolve freshlyResolved:(BOOL *)freshlyResolved {
    @synchronized(listOfIPs) {
        *freshlyResolved = NO;
        if (forceResolve == YES || listOfIPs == nil || [listOfIPs count] == 0) {
            ServerDiscovery *sd = [[self alloc] init];
            [sd forcedResolveWithWait];
            *freshlyResolved = YES;
            [sd release];
        }
        return [[listOfIPs copy] autorelease];
    }
}

- (void)forcedResolveWithWait {
    self.resolveDone = NO;
    [self.netService resolveWithTimeout:5.0];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    NSLog(@"Entering runloop wait");
    while (self.resolveDone == NO && [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]])
        NSLog(@"...spinning...");
    NSLog(@"Released from runloop wait");

}

- (id)init {
    if ((self = [super init])) {
        if (listOfIPs == nil)
            listOfIPs = [[NSMutableArray alloc] initWithCapacity:10];
        _netService = [[NSNetService alloc] initWithDomain:@"local." type:@"_http._tcp." name:@"iotaMedSrv"];
        _netService.delegate = self;
    }
    return self;
}

- (void)dealloc {
    [self.netService stop];
    _netService.delegate = nil;
    self.netService = nil;
    [super dealloc];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Get addresses
// -----------------------------------------------------------

- (void)resolve {
    [self.netService resolveWithTimeout:5.0];
}

- (NSArray *)iotaSrvAddressList {
    @synchronized(listOfIPs) {
        return [[listOfIPs copy] autorelease];
    }
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark NSNetServiceDelegate
// -----------------------------------------------------------

/* Sent to the NSNetService instance's delegate prior to advertising the service on the network. If for some reason the service cannot be published, the delegate will not receive this message, and an error will be delivered to the delegate via the delegate's -netService:didNotPublish: method.
 */
- (void)netServiceWillPublish:(NSNetService *)sender {
    
}

/* Sent to the NSNetService instance's delegate when the publication of the instance is complete and successful.
 */
- (void)netServiceDidPublish:(NSNetService *)sender {
    
}

/* Sent to the NSNetService instance's delegate when an error in publishing the instance occurs. The error dictionary will contain two key/value pairs representing the error domain and code (see the NSNetServicesError enumeration above for error code constants). It is possible for an error to occur after a successful publication.
 */
- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict {
    
}

/* Sent to the NSNetService instance's delegate prior to resolving a service on the network. If for some reason the resolution cannot occur, the delegate will not receive this message, and an error will be delivered to the delegate via the delegate's -netService:didNotResolve: method.
 */
- (void)netServiceWillResolve:(NSNetService *)sender {
    NSLog(@"Netservice will resolve");
}

/* Sent to the NSNetService instance's delegate when one or more addresses have been resolved for an NSNetService instance. Some NSNetService methods will return different results before and after a successful resolution. An NSNetService instance may get resolved more than once; truly robust clients may wish to resolve again after an error, or to resolve more than once.
 */
- (void)netServiceDidResolveAddress:(NSNetService *)sender {
    // it's ok to lock synchronized again, since it's on the same thread as the previous synch
    @synchronized(listOfIPs) {
        [listOfIPs removeAllObjects];
        NSArray *addresses = [sender addresses];
        NSLog(@"Did resolve");
        char addr[256];
        for (int i = 0; i < [addresses count]; i++) {
            struct sockaddr *socketAddress = (struct sockaddr *)[[addresses objectAtIndex:i] bytes];
            if (socketAddress && socketAddress->sa_family == AF_INET) {
                if (inet_ntop(AF_INET, &((struct sockaddr_in *)socketAddress)->sin_addr, addr, sizeof(addr))) {
                    uint16_t port = ntohs(((struct sockaddr_in *)socketAddress)->sin_port);
                    NSString *address = [NSString stringWithFormat:@"%s:%d", addr, port];
                    [listOfIPs addObject:address];
                    NSLog(@"%s:%d", addr, port);
                }
            }
        }
    }
    NSLog(@"ServerDiscovery::netServiceDidResolveAddresses (YES)");
    self.resolveDone = YES;
}

/* Sent to the NSNetService instance's delegate when an error in resolving the instance occurs. The error dictionary will contain two key/value pairs representing the error domain and code (see the NSNetServicesError enumeration above for error code constants).
 */
- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
    NSLog(@"Did not resolve");
    self.resolveDone = YES;
}

/* Sent to the NSNetService instance's delegate when the instance's previously running publication or resolution request has stopped.
 */
- (void)netServiceDidStop:(NSNetService *)sender {
    NSLog(@"Netservice did stop");
}

/* Sent to the NSNetService instance's delegate when the instance is being monitored and the instance's TXT record has been updated. The new record is contained in the data parameter.
 */
- (void)netService:(NSNetService *)sender didUpdateTXTRecordData:(NSData *)data {
    NSLog(@"Did update TXT record data");
}


@end
