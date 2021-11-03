import Foundation

let handle = dlopen("/System/Library/Frameworks/IOKit.framework/IOKit", 2);

@objc protocol IOHIDEvent: NSObjectProtocol {};

typealias IOHIDEventSystemClientCreate = @convention(c) (_ allocator: CFAllocator?) -> IOHIDEventSystemClient;
typealias IOHIDEventSystemClientSetMatching = @convention(c) (_ client: IOHIDEventSystemClient?, _ matches: CFDictionary?) -> Void;
typealias IOHIDServiceClientCopyEvent = @convention(c) (_ client: IOHIDServiceClient, Int64, Int32, Int64) -> IOHIDEvent;
typealias IOHIDEventGetFloatValue = @convention(c) (_ event: IOHIDEvent, _ field: UInt32) -> Double;
typealias IOHIDServiceClientCopyProperty = @convention(c) (_ service: IOHIDServiceClient, _ property: CFString) -> CFString;

let eventSystemClientCreate = unsafeBitCast(dlsym(handle, "IOHIDEventSystemClientCreate"), to: IOHIDEventSystemClientCreate.self);
let eventSystemClientSetMatching = unsafeBitCast(dlsym(handle, "IOHIDEventSystemClientSetMatching"), to: IOHIDEventSystemClientSetMatching.self);
let serviceClientCopyEvent = unsafeBitCast(dlsym(handle, "IOHIDServiceClientCopyEvent"), to: IOHIDServiceClientCopyEvent.self);
let eventGetFloatValue = unsafeBitCast(dlsym(handle, "IOHIDEventGetFloatValue"), to: IOHIDEventGetFloatValue.self);
let serviceClientCopyProperty = unsafeBitCast(dlsym(handle, "IOHIDServiceClientCopyProperty"), to: IOHIDServiceClientCopyProperty.self);

let client: IOHIDEventSystemClient = eventSystemClientCreate(kCFAllocatorDefault);

eventSystemClientSetMatching(client, [
    "PrimaryUsage": 5,
    "PrimaryUsagePage": 65280
] as CFDictionary);

let devices: CFArray? = IOHIDEventSystemClientCopyServices(client);

var temps: [String: Double] = [:]
var total: Double = 0.0;
var average: String = "0";

for device in devices as! [IOHIDServiceClient] {
    let event: IOHIDEvent = serviceClientCopyEvent(device, 15, 0, 0);
    let name: CFString = serviceClientCopyProperty(device, "Product" as CFString);
    let temp = eventGetFloatValue(event, 983040);
    temps[name as String] = temp;
    total += temp;
}

average = String(format: "%.2f", total / Double(temps.count));

print("\(average)°C");

dlclose(handle);
