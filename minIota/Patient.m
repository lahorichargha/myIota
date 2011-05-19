//
//  Patient.m
//  iotaPad6
//
//  Created by Martin on 2011-02-11.
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

#import "Patient.h"
#import "NSString+iotaAdditions.h"

@implementation Patient

static NSString *kPatientIdKey = @"patientIdKey";
static NSString *kFirstNameKey = @"firstNameKey";
static NSString *kLastNameKey = @"lastNameKey";

// -----------------------------------------------------------
#pragma mark -
#pragma mark Properties
// -----------------------------------------------------------

@synthesize patientID = _patientID;
@synthesize firstName = _firstName;
@synthesize lastName = _lastName;

// -----------------------------------------------------------
#pragma mark -
#pragma mark Convencience constructors
// -----------------------------------------------------------

+ (Patient *)patientWithID:(NSString *)patientID firstName:(NSString *)firstName lastName:(NSString *)lastName {
    Patient *newPatient = [[[Patient alloc] init] autorelease];
    newPatient.patientID = patientID;
    newPatient.firstName = firstName;
    newPatient.lastName = lastName;
    return newPatient;
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Class methods
// -----------------------------------------------------------

+ (NSString *)buttonTitleForPatient:(Patient *)patient {
    if (patient != nil) {
        return [NSString stringWithFormat:@"%@ - %@ %@", patient.patientID, patient.firstName, patient.lastName]; 
    }
    else {
        return @"<Ingen patient vald>";
    }
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Object lifecycle
// -----------------------------------------------------------

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        self.patientID = [aDecoder decodeObjectForKey:kPatientIdKey];
        self.firstName = [aDecoder decodeObjectForKey:kFirstNameKey];
        self.lastName = [aDecoder decodeObjectForKey:kLastNameKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.patientID forKey:kPatientIdKey];
    [aCoder encodeObject:self.firstName forKey:kFirstNameKey];
    [aCoder encodeObject:self.lastName forKey:kLastNameKey];
}

- (void)dealloc {
    self.patientID = nil;
    self.firstName = nil;
    self.lastName = nil;
    [super dealloc];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Debug stuff
// -----------------------------------------------------------

- (void)dumpWithIndent:(int)indent {
    NSLog(@"%@Patient: %@", [NSString spacesOfLength:indent], [[self class] buttonTitleForPatient:self]);
}

@end
