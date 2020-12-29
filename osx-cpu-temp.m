// This code is originally from https://github.com/freedomtan/sensors/blob/master/sensors/sensors.m
// Here is the original code's license

// BSD 3-Clause License

// Copyright (c) 2016-2018, "freedom" Koan-Sin Tan
// All rights reserved.

// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:

// * Redistributions of source code must retain the above copyright notice, this
//   list of conditions and the following disclaimer.

// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.

// * Neither the name of the copyright holder nor the names of its
//   contributors may be used to endorse or promote products derived from
//   this software without specific prior written permission.

// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#include <IOKit/hidsystem/IOHIDEventSystemClient.h>
#include <Foundation/Foundation.h>
#include <stdio.h>

typedef struct __IOHIDEvent *IOHIDEventRef;
typedef struct __IOHIDServiceClient *IOHIDServiceClientRef;
#ifdef __LP64__
typedef double IOHIDFloat;
#else
typedef float IOHIDFloat;
#endif

IOHIDEventSystemClientRef IOHIDEventSystemClientCreate(CFAllocatorRef allocator);
int IOHIDEventSystemClientSetMatching(IOHIDEventSystemClientRef client, CFDictionaryRef match);
int IOHIDEventSystemClientSetMatchingMultiple(IOHIDEventSystemClientRef client, CFArrayRef match);
IOHIDEventRef IOHIDServiceClientCopyEvent(IOHIDServiceClientRef, int64_t , int32_t, int64_t);
CFStringRef IOHIDServiceClientCopyProperty(IOHIDServiceClientRef service, CFStringRef property);
IOHIDFloat IOHIDEventGetFloatValue(IOHIDEventRef event, int32_t field);

CFDictionaryRef matching(int page, int usage)
{
    CFNumberRef nums[2];
    CFStringRef keys[2];

    keys[0] = CFStringCreateWithCString(0, "PrimaryUsagePage", 0);
    keys[1] = CFStringCreateWithCString(0, "PrimaryUsage", 0);
    nums[0] = CFNumberCreate(0, kCFNumberSInt32Type, &page);
    nums[1] = CFNumberCreate(0, kCFNumberSInt32Type, &usage);

    CFDictionaryRef dict = CFDictionaryCreate(0, (const void**)keys, (const void**)nums, 2, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    return dict;
}

CFArrayRef getProductNames(CFDictionaryRef sensors) {
    IOHIDEventSystemClientRef system = IOHIDEventSystemClientCreate(kCFAllocatorDefault);
    IOHIDEventSystemClientSetMatching(system, sensors);
    CFArrayRef matchingsrvs = IOHIDEventSystemClientCopyServices(system);

    long count = CFArrayGetCount(matchingsrvs);
    CFMutableArrayRef array = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    for (int i = 0; i < count; i++) {
        IOHIDServiceClientRef sc = (IOHIDServiceClientRef)CFArrayGetValueAtIndex(matchingsrvs, i);
        CFStringRef name = IOHIDServiceClientCopyProperty(sc, CFSTR("Product"));
        if (name) {
            CFArrayAppendValue(array, name);
        } else {
            CFArrayAppendValue(array, @"noname");
        }
    }
    return array;
}

#define IOHIDEventFieldBase(type)   (type << 16)
#define kIOHIDEventTypeTemperature  15

CFArrayRef getThermalValues(CFDictionaryRef sensors) {
    IOHIDEventSystemClientRef system = IOHIDEventSystemClientCreate(kCFAllocatorDefault);
    IOHIDEventSystemClientSetMatching(system, sensors);
    CFArrayRef matchingsrvs = IOHIDEventSystemClientCopyServices(system);

    long count = CFArrayGetCount(matchingsrvs);
    CFMutableArrayRef array = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);

    for (int i = 0; i < count; i++) {
        IOHIDServiceClientRef sc = (IOHIDServiceClientRef)CFArrayGetValueAtIndex(matchingsrvs, i);
        IOHIDEventRef event = IOHIDServiceClientCopyEvent(sc, kIOHIDEventTypeTemperature, 0, 0);

        CFNumberRef value;
        if (event != 0) {
            double temp = IOHIDEventGetFloatValue(event, IOHIDEventFieldBase(kIOHIDEventTypeTemperature));
            value = CFNumberCreate(kCFAllocatorDefault, kCFNumberDoubleType, &temp);
        } else {
            double temp = 0;
            value = CFNumberCreate(kCFAllocatorDefault, kCFNumberDoubleType, &temp);
        }
        CFArrayAppendValue(array, value);
    }
    return array;
}

int main () {
    NSString *cpusensors[24];
    cpusensors[0] = @"ANE MTR Temp Sensor1";
    cpusensors[1] = @"ISP MTR Temp Sensor5";
    cpusensors[2] = @"PMGR SOC Die Temp Sensor0";
    cpusensors[3] = @"PMGR SOC Die Temp Sensor1";
    cpusensors[4] = @"PMGR SOC Die Temp Sensor2";
    cpusensors[5] = @"PMU tdie1";
    cpusensors[6] = @"PMU tdie2";
    cpusensors[7] = @"PMU tdie4";
    cpusensors[8] = @"PMU tdie5";
    cpusensors[9] = @"PMU tdie6";
    cpusensors[10] = @"PMU tdie7";
    cpusensors[11] = @"PMU tdie8";
    cpusensors[12] = @"SOC MTR Temp Sensor0";
    cpusensors[13] = @"SOC MTR Temp Sensor1";
    cpusensors[14] = @"SOC MTR Temp Sensor2";
    cpusensors[15] = @"eACC MTR Temp Sensor0";
    cpusensors[16] = @"eACC MTR Temp Sensor3";
    cpusensors[17] = @"pACC MTR Temp Sensor2";
    cpusensors[18] = @"pACC MTR Temp Sensor3";
    cpusensors[19] = @"pACC MTR Temp Sensor4";
    cpusensors[20] = @"pACC MTR Temp Sensor5";
    cpusensors[21] = @"pACC MTR Temp Sensor7";
    cpusensors[22] = @"pACC MTR Temp Sensor8";
    cpusensors[23] = @"pACC MTR Temp Sensor9";
    NSArray *cpusensorarray = [NSArray arrayWithObjects:cpusensors count:24];

    CFDictionaryRef thermalSensors = matching(0xff00, 5);
    CFArrayRef thermalNames = getProductNames(thermalSensors);
    CFArrayRef thermalValues = getThermalValues(thermalSensors);
    long count = CFArrayGetCount(thermalNames);
    double tempSum = 0.0;
    for (int i = 0; i < count; i++) {
      NSString *name = (NSString *)CFArrayGetValueAtIndex(thermalNames, i);
      if ([cpusensorarray containsObject:name]) {
        double temp = 0.0;
        CFNumberGetValue(CFArrayGetValueAtIndex(thermalValues, i), kCFNumberDoubleType, &temp);
        tempSum += temp;
      }
    }
    double averageTemp = tempSum / 24.0;
    printf("%0.1lf°C\n", averageTemp);
    CFRelease(thermalNames);
    CFRelease(thermalValues);
  return 0;
}
