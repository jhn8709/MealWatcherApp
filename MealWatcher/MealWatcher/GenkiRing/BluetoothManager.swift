//
//  BluetoothManager.swift
//  XCode Demo
//
//  Created by Jimmy Nguyen on 7/17/23.
//

import Foundation
import CoreBluetooth


extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }

    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return self.map { String(format: format, $0) }.joined()
    }
}

class BluetoothViewModel: NSObject, ObservableObject, CBPeripheralDelegate {
    static let instance = BluetoothViewModel()
    private var centralManager: CBCentralManager?
    private var peripherals: [CBPeripheral] = []
    @Published var peripheralNames: [String] = []
    @Published var connectedPeripheral: CBPeripheral?
    @Published var waveRing: CBPeripheral?
    @Published var APICharacteristic: CBCharacteristic?
    //let csv = CSVManager.instance
    let wavePacketLength = 111
    let maxPacketLength = 256
    var wavePacketTotalBytes: Int = 0
    //var wavePacket = [UInt8](repeating: 0, count: 260)
    var wavePacket: [UInt8] = []
    let file_manager = LocalFileManager.instance
    let vm = FileManagerViewModel()
    @Published var filename: String?
    @Published var timeOffset: UInt64?
    @Published var allowNotifications: Bool = false
    @Published var currentURL: URL?
    // Initialize an NSOutputStream instance
    var outputStream: OutputStream?
    let serviceUUID = CBUUID(string: "65E9296C-8DFB-11EA-BC55-0242AC130003")
    
    @Published private var timer: Timer?
    @Published private var counter = 0
    @Published var errorFlag: Bool = false
    @Published private var isTimerRunning: Bool = false
    @Published var isRunning: Bool = false

    
    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: .main)
    }
    
    // Connecting to a peripheral
    func connect(peripheral: CBPeripheral) {
        centralManager?.connect(peripheral, options: nil)
     }
    
    func connectWithUUID(ringUUID: UUID) {
        // Retrieve the peripherals with the specified UUID
        let connectedPeripherals = centralManager?.retrievePeripherals(withIdentifiers: [ringUUID])
        // Connect to the retrieved peripheral
        if let device = connectedPeripherals?.first {
            centralManager?.connect(device, options: nil)
        }

    }
        
    func disconnect(peripheral: CBPeripheral) {
        centralManager?.cancelPeripheralConnection(peripheral)
        self.timeOffset = nil
        guard let filename = self.filename else {return}
        self.file_manager.closeFile(filename: filename)

    }
    
    // Call after connecting to peripheral
    func discoverServices(peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
    }
     
    // Call after discovering services
    func discoverCharacteristics(peripheral: CBPeripheral) {
        guard let services = peripheral.services else {
            return
        }
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func discoverDescriptors(peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        peripheral.discoverDescriptors(for: characteristic)
    }
    
    // reads characteristic
    func readValue(characteristic: CBCharacteristic) {
        self.connectedPeripheral?.readValue(for: characteristic)
    }
    
    func getUUID(peripheral: CBPeripheral) -> UUID? {
        // Assuming you have a connected peripheral stored in the variable 'connectedPeripheral'
        if let connectedPeripheral = self.connectedPeripheral {
            let deviceUUID = connectedPeripheral.identifier
            print("UUID of the connected Bluetooth device: \(deviceUUID)")
            return deviceUUID
        }
        else {
            return nil
        }

    }
}

extension BluetoothViewModel: CBCentralManagerDelegate {
    // gives state of the central manager
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            self.centralManager?.scanForPeripherals(withServices: nil)
        }
    }
    
    // provides list of BLE device names
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !peripherals.contains(peripheral) {
            self.peripherals.append(peripheral)
            self.peripheralNames.append(peripheral.name ?? "unnamed device")
            if peripheral.name == "Wave" {
                print("Found Wave!")
                self.waveRing = peripheral

            }
        }
    }
    
    // Handles connection
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // Successfully connected. Store reference to peripheral if not already done.
        self.connectedPeripheral = peripheral
        peripheral.delegate = self
        print("Successfully connected to", peripheral.name ?? "unnamed device")
        //guard let ring = self.waveRing else {return}
        guard let ring = self.connectedPeripheral else {return}
        discoverServices(peripheral: ring)
    }
     
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        // Handle error
        self.isRunning = false
    }
    
    // Handles disconnection
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let error = error {
            // Handle error
            print("\(error)")
            self.isRunning = false
            return
        }
        // Successfully disconnected
        self.isRunning = false
    }
    
    // Discover services and characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            return
        }
        discoverCharacteristics(peripheral: peripheral)
        //print("Services: \(services)")
    }
     
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            return
        }
        //print("Characteristics: \(characteristics)")
        // Consider storing important characteristics internally for easy access and equivalency checks later.
        // From here, can read/write to characteristics or subscribe to notifications as desired.
        for characteristic in characteristics {
            peripheral.discoverDescriptors(for: characteristic)
            if characteristic.uuid == CBUUID(string: "65e92bb1-8dfb-11ea-bc55-0242ac130003") {
                self.APICharacteristic = characteristic
                if allowNotifications == true {
                    print("Starting notifications for ring")
                    self.startTimer()
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
        }
    }
    
    func setNotifyOff() {
        guard let peripheral = self.connectedPeripheral else {return}
        guard let characteristic = self.APICharacteristic else {return}
        peripheral.setNotifyValue(false, for: characteristic)
        //self.csv.readDataFromCSVFile(filename: "data")
        //self.csv.deleteCSVFile()
    }
    
    // Discover descriptors
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        guard let descriptors = characteristic.descriptors else { return }
        
        //print("\(descriptors)")
     
        // Get user description descriptor
        if let userDescriptionDescriptor = descriptors.first(where: {
            return $0.uuid.uuidString == CBUUIDCharacteristicUserDescriptionString
        }) {
            // Read user description for characteristic
            peripheral.readValue(for: userDescriptionDescriptor)
        }
    }
    
//    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
//        if let error = error {
//            print("Error enabling notifications: \(error.localizedDescription)")
//        } else {
//            print("Notifications enabled for \(characteristic.uuid)")
//        }
//    }
     
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        // Get and print user description for a given characteristic
        if descriptor.uuid.uuidString == CBUUIDCharacteristicUserDescriptionString,
            let userDescription = descriptor.value as? String {
            print("Characterstic \(String(describing: descriptor.characteristic?.uuid.uuidString)) is also known as \(userDescription)")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        guard characteristic == self.APICharacteristic, let characteristicValue = characteristic.value else {
            print("Can't decode characteristic value")
            return
        }
        if self.isTimerRunning {
            self.stopTimer()
            self.isRunning = true
        }
        let byteArray = [UInt8](characteristicValue)
        for i in 0..<byteArray.count {
            //self.wavePacket[self.wavePacketTotalBytes] = byteArray[i]
            self.wavePacket.append(byteArray[i])
            self.wavePacketTotalBytes += 1
            if self.wavePacketTotalBytes >= self.maxPacketLength {
                self.wavePacketTotalBytes = 0
                continue
            }
            if byteArray[i] != 0 {
                continue
            }
            var sensorData = zeroParams()
            if let decodedData = decodeCOBS(wavePacket) {
                sensorData.gyrox = littleEndianHexToFloat(Array(decodedData[4..<8]))
                sensorData.gyroy = littleEndianHexToFloat(Array(decodedData[8..<12]))
                sensorData.gyroz = littleEndianHexToFloat(Array(decodedData[12..<16]))
                sensorData.accx = littleEndianHexToFloat(Array(decodedData[16..<20]))
                sensorData.accy = littleEndianHexToFloat(Array(decodedData[20..<24]))
                sensorData.accz = littleEndianHexToFloat(Array(decodedData[24..<28]))
                sensorData.magFieldx = littleEndianHexToFloat(Array(decodedData[28..<32]))
                sensorData.magFieldy = littleEndianHexToFloat(Array(decodedData[32..<36]))
                sensorData.magFieldz = littleEndianHexToFloat(Array(decodedData[36..<40]))
                sensorData.attitudew = littleEndianHexToFloat(Array(decodedData[56..<60]))
                sensorData.attitudex = littleEndianHexToFloat(Array(decodedData[60..<64]))
                sensorData.attitudey = littleEndianHexToFloat(Array(decodedData[64..<68]))
                sensorData.attitudez = littleEndianHexToFloat(Array(decodedData[68..<72]))
                sensorData.linaccx = littleEndianHexToFloat(Array(decodedData[84..<88]))
                sensorData.linaccy = littleEndianHexToFloat(Array(decodedData[88..<92]))
                sensorData.linaccz = littleEndianHexToFloat(Array(decodedData[92..<96]))
                let ringTimeStamp = getTimeStamp(Array(decodedData[101..<109]))
                if self.timeOffset == nil {
                    let since1970 = Date().timeIntervalSince1970 // Get the time interval since Jan 1, 1970
                    let timeInMilliseconds = UInt64(since1970 * 1000) // Convert the time interval to milliseconds
                    self.timeOffset = timeInMilliseconds - ringTimeStamp/1000
                }
                sensorData.time = ringTimeStamp/1000 + (self.timeOffset ?? 0)
//                print("gyrox:",gyrox,"gyroy:",gyroy,"gyroz:",gyroz,"accx:",accx,"accy:",accy,"accz",accz)
//                print("Header is [\(wavePacket[0]), \(wavePacket[1]), \(wavePacket[2]), \(wavePacket[3])]. timestamp: \(sensorData.time)")
                let binaryData = Data(bytes: &sensorData, count: MemoryLayout<sensorParam>.size)
                writeToStream(data: binaryData)
                
            } else {
                print("Failed to decode COBS-encoded data.")
            }
            self.wavePacketTotalBytes = 0
            self.wavePacket = []
        }
    
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            // Handle the error if the write operation fails
            print("Error writing value to characteristic: \(error.localizedDescription)")
        } else {
            // Write operation successful
            print("Value written to characteristic successfully")
        }
    }
    
    // Function to write data to the stream
    func writeToStream(data: Data) {
        guard let stream = self.outputStream else {
            print("Stream is not open")
            return
        }
        
        let buffer = [UInt8](data)
        let bytesWritten = stream.write(buffer, maxLength: buffer.count)
        if bytesWritten < 0 {
            print("Write error")
        }
    }
    
    // Function to start recording
    func startRecording(fileURL: URL) {
        self.outputStream = OutputStream(url: fileURL, append: true)
        self.outputStream?.open()

    }
    
    // Function to stop recording
    func stopRecording() {
        self.outputStream?.close()
    }
    
    func startTimer() {
        // Invalidate the existing timer, if any
        timer?.invalidate()
        isTimerRunning = true
        // Create a new timer that fires every 1 second
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            // Update the counter or perform any action you want
            self.counter += 1
            
            // Check if you want to stop the timer after a certain condition
            if self.counter >= 2 {
                print("No recording for 2 seconds, send alert")
                self.errorFlag.toggle()
                self.stopTimer()
            }
        }
        
        // Make sure the timer is added to the current run loop
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    func stopTimer() {
        // Invalidate the timer when you want to stop it
        print("Timer being stopped")
        isTimerRunning = false
        timer?.invalidate()
    }
}
