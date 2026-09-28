// import 'package:flutter/material.dart';
// import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
// import 'dart:async';
// // import 'dart:typed_data';

// class BluetoothState {
//   final FlutterReactiveBle flutterReactiveBle;
//   final ValueNotifier<bool> connected = ValueNotifier<bool>(false);
//   final ValueNotifier<String> weightData = ValueNotifier<String>('0.0');
//   DiscoveredDevice? connectedDevice;
//   StreamSubscription<ConnectionStateUpdate>? _connection;
//   StreamSubscription<List<int>>? _weightSubscription;

//   BluetoothState(this.flutterReactiveBle);

//   // Connect to the Bluetooth device
//   void connectToDevice(DiscoveredDevice device) {
//     if (connected.value && connectedDevice?.id == device.id) {
//       debugPrint("Already connected to a device.");
//       return; // Prevent multiple connection attempts
//     }

//     try {
//       // Cancel previous connection if any
//       _connection?.cancel();

//       _connection = flutterReactiveBle.connectToDevice(id: device.id).listen(
//         (connectionState) {
//           if (connectionState.connectionState ==
//               DeviceConnectionState.connected) {
//             connected.value = true;
//             connectedDevice = device;
//             _discoverServices(device);
//           } else if (connectionState.connectionState ==
//               DeviceConnectionState.disconnected) {
//             _handleDisconnection();
//           }
//         },
//         onError: (error) {
//           debugPrint("Connection error: $error");
//           _handleDisconnection();
//         },
//       );
//     } catch (error) {
//       debugPrint("Error connecting to device: $error");
//     }
//   }

//   // Handle disconnection process
//   void _handleDisconnection() {
//     connected.value = false;
//     connectedDevice = null;
//     _weightSubscription?.cancel();
//     debugPrint("Device disconnected.");
//   }

//   // Discover services and subscribe to weight data
//   Future<void> _discoverServices(DiscoveredDevice device) async {
//     try {
//       // ignore: deprecated_member_use
//       final services = await flutterReactiveBle.discoverServices(device.id);
//       for (var service in services) {
//         for (var characteristic in service.characteristics) {
//           if (characteristic.isNotifiable || characteristic.isReadable) {
//             final qualifiedCharacteristic = QualifiedCharacteristic(
//               characteristicId: characteristic.characteristicId,
//               serviceId: service.serviceId,
//               deviceId: device.id,
//             );

//             // Subscribe to the weight data characteristic
//             _weightSubscription
//                 ?.cancel(); // Cancel previous subscription if any
//             _weightSubscription = flutterReactiveBle
//                 .subscribeToCharacteristic(qualifiedCharacteristic)
//                 .listen(
//               (data) {
//                 String weight =
//                     convertToWeight(data); // Implement this function
//                 // final weightValue = _parseWeight(data);
//                 // Fluttertoast.showToast(msg: 'Received Weight Data 1.0: $weight');
//                 // Fluttertoast.showToast(msg: 'Received Weight Data 1.1: $weightValue');

//                 weightData.value = weight; // Update the weight data
//                 // weightData.value = weightValue.toStringAsFixed(1);
//               },
//               onError: (error) {
//                 debugPrint("Error receiving weight data: $error");
//                 _handleDisconnection();
//               },
//             );
//           }
//         }
//       }
//     } catch (error) {
//       debugPrint("Error discovering services: $error");
//       _handleDisconnection();
//     }
//   }

//   // Convert raw data from Bluetooth characteristic to a readable weight string
//   String convertToWeight(List<int> data) {
//     List<int> reversedData = data.reversed.toList();
//     String rawWeightString = String.fromCharCodes(reversedData);

//     // Remove any unwanted characters, like the '=' sign
//     rawWeightString = rawWeightString.replaceAll('=', '');

//     // Convert the cleaned string to a double and format it to 2 decimal places
//     double weightValue = double.tryParse(rawWeightString) ?? 0.0;

//     // Return the formatted weight as a string with 2 decimal places
//     return weightValue.toStringAsFixed(2);
//   }

//   // Parse weight data from Bluetooth
//   // double _parseWeight(List<int> data) {
//   //   if (data.length == 8) {
//   //     var byteData = ByteData.sublistView(Uint8List.fromList(data));
//   //     // var byteData = ByteData.sublistView(Uint8List.fromList(data));
//   //     double floatValue = byteData.getFloat32(0, Endian.little);
//   //     print('Float Value: $floatValue');
//   //     print('BYTE: ${byteData.toString()}');
//   //     double littleEndianWeight = byteData.getFloat32(0, Endian.little);
//   //     double bigEndianWeight = byteData.getFloat32(0, Endian.big);
//   //     print('LITTLE: $littleEndianWeight');
//   //     print('BIG: $bigEndianWeight');
//   //     return littleEndianWeight > bigEndianWeight
//   //         ? bigEndianWeight
//   //         : littleEndianWeight;
//   //   } else {
//   //     print("Unknown data length: ${data.length}");
//   //     return 0.0;
//   //   }
//   // }

//   // Disconnect from the device and clean up resources
//   Future<void> disconnectDevice() async {
//     try {
//       await _connection?.cancel();
//       _weightSubscription?.cancel();
//       connected.value = false;
//       connectedDevice = null;
//     } catch (error) {
//       return;
//     }
//   }

//   void dispose() {
//     _connection?.cancel();
//     _weightSubscription?.cancel();
//   }
// }
