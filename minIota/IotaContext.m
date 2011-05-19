//
//  IotaContext.m
//  iotaPad6
//
//  Created by Martin on 2011-02-15.
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

#import "IotaContext.h"
#import "Patient.h"
#import "PatientContextDB.h"
#import "IDRWorksheet.h"
#import "IDRBlock.h"
#import "XML2IDR.h"
#import "NSString+iotaAdditions.h"
#import "Notifications.h"
#import "ServerDiscovery.h"
#import "MyIotaPatientContext.h"


// -----------------------------------------------------------
#pragma mark -
#pragma mark Local declarations
// -----------------------------------------------------------

@interface IotaContext()

- (void)_addObserver:(id <IotaContextDelegate>) observer;
- (void)_removeObserver:(id <IotaContextDelegate>) observer;
- (void)_saveCurrentPatientContext;
- (void)_loadNewPatient:(Patient *)newPatient;


@property (nonatomic, retain) NSMutableArray *observers;
@property (nonatomic, retain) PatientContext *currentPatientContext;
@property (nonatomic, retain) PatientContext *currentMyIotaContext;

@property (nonatomic, retain) NSMutableDictionary *worksheets;
@property (nonatomic, retain) NSMutableDictionary *blocks;

@property (nonatomic, retain) Patient *newPatient;
@property (nonatomic, retain) PatientContextDB *patientContextDb;

@end

// -----------------------------------------------------------
#pragma mark -
#pragma mark Properties
// -----------------------------------------------------------

@implementation IotaContext

@synthesize observers = _observers;
@synthesize currentPatientContext = _currentPatientContext;
@synthesize currentMyIotaContext = _currentMyIotaContext;

@synthesize worksheets = _worksheets;
@synthesize blocks = _blocks;

@synthesize newPatient = _newPatient;
@synthesize patientContextDb = _patientContextDb;

// -----------------------------------------------------------
#pragma mark -
#pragma mark Singleton implementation
// -----------------------------------------------------------

static IotaContext * volatile _sharedInstance = nil;

+ (IotaContext *)_sharedInstance {
    if (_sharedInstance == nil) {
        @synchronized(self) {
            if (_sharedInstance == nil) {
                _sharedInstance = [[self alloc] init];
            }
        }
    }
    return _sharedInstance;
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Object lifecycle
// -----------------------------------------------------------

- (id)init {
    if ((self = [super init])) {
        _observers = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(memoryLowNotification:) name:kLowMemoryNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.newPatient = nil;
    self.observers = nil;
    self.currentPatientContext = nil;
    self.currentMyIotaContext = nil;
    self.worksheets = nil;
    self.blocks = nil;
    self.patientContextDb = nil;
    [super dealloc];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Class methods
// -----------------------------------------------------------

+ (void)setPresetPatient {
    Patient *patient = [Patient patientWithID:[self patientId] firstName:[self patientFirstName] lastName:[self patientLastName]];
    [[self _sharedInstance] _loadNewPatient:patient];
}

+ (void)addObserver:(id <IotaContextDelegate>)observer {
    [[self _sharedInstance] _addObserver:observer];
}

+ (void)removeObserver:(id <IotaContextDelegate>)observer {
    [[self _sharedInstance] _removeObserver:observer];
}


+ (NSString *)patientFirstName {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"patientFirstName"];
}

+ (NSString *)patientLastName {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"patientLastName"];
}

+ (NSString *)patientId {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"patientId"];
}


+ (CGFloat)minRowHeight {
    CGFloat rowHeight = [[[NSUserDefaults standardUserDefaults] objectForKey:@"minRowHeight"] floatValue];
    return fmax(rowHeight, 30.0);
}



// -----------------------------------------------------------
#pragma mark -
#pragma mark Patient context
// -----------------------------------------------------------

+ (PatientContext *)getCurrentPatientContext {
    @synchronized(self) {
        return [self _sharedInstance].currentPatientContext;
    }
}

+ (PatientContext *)getCurrentMyIotaContext {
    @synchronized(self) {
        return [self _sharedInstance].currentMyIotaContext;
    }
}

+ (void)saveCurrentPatientContext {
    [[self _sharedInstance] _saveCurrentPatientContext];
}



// -----------------------------------------------------------
#pragma mark -
#pragma mark Instance methods
// -----------------------------------------------------------

- (Patient *)_currentPatient {
    if (self.currentPatientContext)
        return self.currentPatientContext.patient;
    else
        return nil;
}

- (void)memoryLowNotification:(NSNotification *)note {
    NSLog(@"Iotacontext low memory notification");
    self.worksheets = nil;
    self.blocks = nil;
}

- (void)_addObserver:(id <IotaContextDelegate>) observer {
    [_observers addObject:observer];
    // always reset client to start with
    [observer didSwitchToPatient:[self _currentPatient]];  
}

- (void)_removeObserver:(id <IotaContextDelegate>) observer {
    [_observers removeObject:observer];
}



// Callback after saving patient context
// =====================================
//  if saving failed
//      send or show error message
//  else if saving was successful
//      tell observers we're about to switch from the patient
//      if any observer says 'NO', stop
//      load new patient

- (void)patientContextSaved:(BOOL)success {
    NSLog(@"patientContextSaved");
    if (!success) {
        NSLog(@"Failed miserably in saving patient context");
        return;
    }
}

- (void)_loadNewPatient:(Patient *)newPatient {
    NSLog(@"loadNewPatient: %@", newPatient.patientID);
    self.patientContextDb = [[[PatientContextDB alloc] init] autorelease];
    self.patientContextDb.delegate = self;
    [self.patientContextDb loadDataForPatient:newPatient];
}



// Callback after loading new patient
// ==================================
//  if loading failed
//      send or show error message
//  else if loading succeeded
//      tell observers we switched to new patient

- (void)loadFromDbDone:(PatientContext *)loadedContext {
    if (loadedContext == nil) {
        NSLog(@"We failed loading patient context");
        [[NSNotificationCenter defaultCenter] postNotificationName:kPatientChangeEnded object:[NSNumber numberWithBool:NO]];
    }
    else {
        NSLog(@"loadFromDbDone");
        self.currentPatientContext = loadedContext;
        for (id <IotaContextDelegate> observer in _observers) {
            [observer didSwitchToPatient:[loadedContext patient]];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kPatientChangeEnded object:[NSNumber numberWithBool:YES]];
    }
    self.patientContextDb = nil;
}

- (void)loadMyIotaFromDbDone:(PatientContext *)loadedContext {
    self.currentMyIotaContext = loadedContext;
    
    self.currentPatientContext = loadedContext;
    for (id <IotaContextDelegate> observer in _observers) {
        [observer didSwitchToPatient:[loadedContext patient]];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kPatientChangeEnded object:[NSNumber numberWithBool:YES]];
    self.patientContextDb = nil;
}

- (void)_saveCurrentPatientContext {
    @synchronized(self) {
        NSLog(@"saveCurrentPatientContext: %@", self.currentPatientContext.patient.patientID);
        PatientContext *pCtx = self.currentPatientContext;
        if (pCtx != nil) {
            pCtx.patient = [self _currentPatient];
            self.patientContextDb = [[[PatientContextDB alloc] initForPatientID:pCtx.patient.patientID withPatientContext:pCtx] autorelease];
            self.patientContextDb.delegate = self;
            [self.patientContextDb putData];
        }
    }
}

- (void)saveToDbDone:(BOOL)success {
    if (!success) {
        NSLog(@"Failed miserably in saving patient context");
        return;
    }
    [self patientContextSaved:success];
    self.patientContextDb = nil;
}

- (void)saveMyIotaToDbDone:(BOOL)success {
    if (!success) {
        NSLog(@"Failed miserably in saving patient myIota");
    }
    self.patientContextDb = nil;
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark PatientContextDelegate
// -----------------------------------------------------------

@end
