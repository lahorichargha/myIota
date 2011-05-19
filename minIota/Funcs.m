//
//  Funcs.m
//  iotaPad6/minIota
//
//  Created by Martin on 2011-03-01.
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

#import "Funcs.h"

BOOL isPortraitOrientation() {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    return (UIInterfaceOrientationIsPortrait(orientation));
}

CGFloat detailWidth() {
    return (isPortraitOrientation()) ? 768.0 : 1024.0 - 320.0;
}

NSDateFormatter *dateFormatterDate() {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyy-MM-dd"];
    return [df autorelease];
}

NSDateFormatter *dateFormatter() {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyy-MM-dd HH:mm"];
    return [df autorelease];
}

// for this kinda shit: 2011-02-28T17:58:00
NSDateFormatter *dateFormatterTypeT() {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss"];
    return [df autorelease];
}

NSDateFormatter *dateFormatterIssueTitles() {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy/MM"];
    return [df autorelease];
}

NSDate *strT2date(NSString *str) {
    NSString *leftStr = [[str componentsSeparatedByString:@"."] objectAtIndex:0];
    return [dateFormatterTypeT() dateFromString:leftStr];
}


NSDate *str2date(NSString *str) {
    return [dateFormatter() dateFromString:str];
}

NSString *date2str(NSDate *date) {
    return [dateFormatter() stringFromDate:date];
}

NSString *dateshort2str(NSDate *date) {
    return [dateFormatterDate() stringFromDate:date];
}


NSString *dateForIssueTitles(NSDate *date) {
    return [dateFormatterIssueTitles() stringFromDate:date];
}

UILabel *navBarLabelWithText(NSString *text) {
    UILabel *lbl = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 400, 44)] autorelease];
    lbl.text = text;
    lbl.backgroundColor = [UIColor clearColor];
    lbl.font = [UIFont boldSystemFontOfSize:20.0];
    lbl.textAlignment = UITextAlignmentCenter;
    lbl.textColor = [UIColor blackColor];
    return lbl;
}

NSString *generateUuidString() {
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = (NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    return [uuidString autorelease];
}

NSDate *combineDateAndTime(NSDate *datePart, NSDate *timePart) {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:datePart];
    NSDateComponents *timeComponents = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:timePart];
    [dateComponents setHour:[timeComponents hour]];
    [dateComponents setMinute:[timeComponents minute]];
    [dateComponents setSecond:[timeComponents second]];
    NSDate *newDate = [calendar dateFromComponents:dateComponents];
    return newDate;
}
