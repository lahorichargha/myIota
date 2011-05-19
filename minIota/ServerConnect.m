//
//  ServerConnect.m
//  iotaPad6
//
//  Created by Martin on 2011-04-20.
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
// we try to send once or twice. If we fail to send the first time,
// we ask ServerDiscovery to do a new resolve, then try again.
// If we fail the second time, we return a failure.

// Flows are as follows:
//
//  recvData
//  ========
//      save patientID to receive from
//      query ServerDiscovery for list of IPs
//
//  sendData method
//  ===============
//      save the data to send
//      query ServerDiscovery for list of IPs
//
//  ServerDiscovery failed (notification from ServerDiscovery)
//  ==========================================================
//      if sendData == nil
//          tell delegate 'done receiving (failed)'
//      else
//          tell delegate 'done sending (failed)'
//
//  list of IPs ready (notification from ServerDiscovery)
//  =====================================================
//      reset pointer to first address in list
//      if sendData == nil
//          goto 'recv from current address'
//      else
//          goto 'send to current address'
//
//  send to current address
//  =======================
//      if pointer is past last address, goto 'send past last address'
//      create a HTTPConnection, give it data and IP and send
//
//  recv from current address
//  =========================
//      if pointer is past last address, goto 'recv past last address'
//      create a HTTPConnection, give it IP and ask for data to recv
//
//  send past last address
//  ======================
//      if list of IPs was with resolve, tell delegate 'done sending (failed)'
//      else query ServerDiscovery for list of IPs with forced resolve
//
//  recv past last address
//  ======================
//      if list of IPs was with resolve, tell delegate 'done receiving (failed)'
//      else query ServerDiscovery for list of IPs with forced resolve
//
//  HTTPConn failed (callback from HTTPConnection)
//  ==============================================
//      increment address pointer
//      if (sendData == nil)
//          goto 'recv from current address'
//      else
//          goto 'send to current address'
//
//  HTTPConn succeeded (callback from HTTPConnection)
//  =================================================
//      if (sendData == nil)
//          tell delegate 'done receiving (success)' with data
//      else
//          tell delegate 'done sending (success)' with data


#import "ServerConnect.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import "ServerDiscovery.h"
#import "Notifications.h"

// -----------------------------------------------------------
#pragma mark -
#pragma mark Local declarations
// -----------------------------------------------------------

@interface ServerConnect ()
@end

// -----------------------------------------------------------
#pragma mark -
#pragma mark Lifecycle
// -----------------------------------------------------------

@implementation ServerConnect


- (id)init {
    NSLog(@"ServerConnect::init");
    if ((self = [super init])) {
    }
    return self;
}

- (void)dealloc {
    NSLog(@"Dealloc ServerConnect");
    [super dealloc];
}

- (NSString *)_folderNameForType:(enum eDataType)datatype {
    return [NSString stringWithCString:eDataTypeStr[(int)datatype] encoding:NSASCIIStringEncoding];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Public entry points
// -----------------------------------------------------------

- (BOOL)_sendDataToIP:(NSString *)ip data:(NSData *)data patientId:(NSString *)patientId datatype:(enum eDataType)datatype {
    NSURLResponse *response;
    NSError *error;
    NSString *strAddr = [NSString stringWithFormat:@"http://%@/%@/%@", ip, patientId,  [self _folderNameForType:datatype]];
    NSURL *url = [NSURL URLWithString:strAddr];
    NSMutableURLRequest *req = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
    [req setHTTPMethod:@"POST"];
    [req setValue:@"binary/iotaMed" forHTTPHeaderField:@"Content-type"];
    [req setHTTPBody:data];
    [req setTimeoutInterval:5];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
    return (responseData != nil);
}

- (BOOL)sendData:(NSData *)data forPatientId:(NSString *)patientId datatype:(enum eDataType)datatype {
    BOOL freshlyResolved;
    NSArray *listOfIPs = [ServerDiscovery getListOfIPsWithForcedResolve:NO freshlyResolved:&freshlyResolved];
    for (NSString *address in listOfIPs) {
        if ([self _sendDataToIP:address data:data patientId:patientId datatype:datatype])
            return YES;
    }
    if (!freshlyResolved) {
        listOfIPs = [ServerDiscovery getListOfIPsWithForcedResolve:YES freshlyResolved:&freshlyResolved];
        for (NSString *address in listOfIPs) {
            if ([self _sendDataToIP:address data:data patientId:patientId datatype:datatype])
                return YES;
        }
    }
    return NO;
}

- (NSData *)_recvDataFromIp:(NSString *)ip patientId:(NSString *)patientId datatype:(enum eDataType)datatype {
    NSString *strAddr = [NSString stringWithFormat:@"http://%@/%@/%@", ip, patientId, [self _folderNameForType:datatype]];
    NSURL *url = [NSURL URLWithString:strAddr];
    NSMutableURLRequest *req = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
    [req setHTTPMethod:@"GET"];
    [req setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
    [req setTimeoutInterval:5];
    NSURLResponse *response;
    NSError *error;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
    return responseData;
}

- (NSData *)recvDataForPatient:(NSString *)patientId datatype:(enum eDataType)datatype {
    BOOL freshlyResolved;
    NSArray *listOfIPs = [ServerDiscovery getListOfIPsWithForcedResolve:NO freshlyResolved:&freshlyResolved];
    for (NSString *address in listOfIPs) {
        NSData *recvdata = [self _recvDataFromIp:address patientId:patientId datatype:datatype];
        if (recvdata != nil)
            return recvdata;
    }
    if (!freshlyResolved) {
        listOfIPs = [ServerDiscovery getListOfIPsWithForcedResolve:YES freshlyResolved:&freshlyResolved];
        for (NSString *address in listOfIPs) {
            NSData *recvdata = [self _recvDataFromIp:address patientId:patientId datatype:datatype];
            if (recvdata != nil)
                return recvdata;
        }
        
    }
    return nil;
}



// -----------------------------------------------------------
#pragma mark -
#pragma mark Helper functions
// -----------------------------------------------------------

@end
