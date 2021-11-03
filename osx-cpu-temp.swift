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

var validSensors: [String] = [
    "ANE MTR Temp Sensor1",
    "ISP MTR Temp Sensor5",
    "PMGR SOC Die Temp Sensor0",
    "PMGR SOC Die Temp Sensor1",
    "PMGR SOC Die Temp Sensor2",
    "PMU tdie1",
    "PMU tdie2",
    "PMU tdie4",
    "PMU tdie5",
    "PMU tdie6",
    "PMU tdie7",
    "PMU tdie8",
    "SOC MTR Temp Sensor0",
    "SOC MTR Temp Sensor1",
    "SOC MTR Temp Sensor2",
    "eACC MTR Temp Sensor0",
    "eACC MTR Temp Sensor3",
    "pACC MTR Temp Sensor2",
    "pACC MTR Temp Sensor3",
    "pACC MTR Temp Sensor4",
    "pACC MTR Temp Sensor5",
    "pACC MTR Temp Sensor7",
    "pACC MTR Temp Sensor8",
    "pACC MTR Temp Sensor9",
];

var sensorCount: Double = 0.0;

for device in devices as! [IOHIDServiceClient] {
    let event: IOHIDEvent = serviceClientCopyEvent(device, 15, 0, 0);
    let name: String = serviceClientCopyProperty(device, "Product" as CFString) as String;
    let temp = eventGetFloatValue(event, 983040);

    if validSensors.contains(name) {
        temps[name as String] = temp;
        total += temp;
        sensorCount += 1.0;
    }

}

average = String(format: "%.2f", total / sensorCount);

if (CommandLine.arguments.count > 1) {
    for argument in CommandLine.arguments {
        if (argument == "--all") {
            print("-------------------------------------");
            for (key, value) in temps {
                print("\(key): \(String(format: "%.2f", value))°C");
            }
            print("-------------------------------------");
            print("Average: \(average)°C");
        }
    }
} else {
    print("\(average)°C");
}

dlclose(handle);
