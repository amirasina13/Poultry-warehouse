import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../config/config.dart';
import '../../../helper/helper.dart';
import '../independent/independent.dart';

class BluetoothWeightPage extends StatefulWidget {
  final BluetoothHelper bluetoothState;
  const BluetoothWeightPage(this.bluetoothState, {Key? key}) : super(key: key);

  @override
  State<BluetoothWeightPage> createState() => _BluetoothWeightPageState();
}

class _BluetoothWeightPageState extends State<BluetoothWeightPage> {
  bool _isScanning = false;
  String connectingDeviceId = '';
  final List<DiscoveredDevice> _discoveredDevices = [];
  late StreamSubscription<DiscoveredDevice> _scanSubscription;
  Timer? scanTimer, connectedTimer;
  BleStatus bleStatus = BleStatus.poweredOff;

  @override
  void initState() {
    super.initState();

    // Listen for Bluetooth being turned on/off
    widget.bluetoothState.flutterReactiveBle.statusStream.listen((status) {
      bleStatus = status;
      if (status == BleStatus.ready) {
        _startScan(); // Start scanning once Bluetooth is turned on
      } else {
        // bluetoothAlert();
        onDisconnection();
      }
    });

    // 2. Listen for Connection State Changes
    // Assuming your bluetoothState (BluetoothHelper) has a stream for connection updates
    // widget.bluetoothState.((state) {
    //   if (state == DeviceConnectionState.disconnected ||
    //       state == DeviceConnectionState.connected) {
    //     if (mounted) {
    //       setState(() {
    //         connectingDeviceId = ''; // This stops the loader
    //         connectedTimer?.cancel(); // Stop the timeout timer
    //       });
    //     }
    //   }
    // });

    _requestPermissions();
    _addConnectedDevice(); // Add connected device if it exists
  }

  Future<void> _requestPermissions() async {
    // Request Bluetooth permissions for Android 12+
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();
  }

  void _addConnectedDevice() {
    if (widget.bluetoothState.connectedDevice != null) {
      setState(() {
        connectingDeviceId = ''; // Reset the loader
      });

      if (_discoveredDevices
          .every((d) => d.id != widget.bluetoothState.connectedDevice!.id)) {
        _discoveredDevices.add(widget.bluetoothState.connectedDevice!);
      }
    }
  }

  Future<void> _startScan() async {
    if (bleStatus != BleStatus.ready) {
      Fluttertoast.showToast(msg: 'turnOnBluetooth'.tr());
      return;
    }

    // If currently scanning, await stopScan to clean up fully first

    if (_isScanning) {
      await stopScan();
    }

    if (!mounted) return;
    setState(() {
      _discoveredDevices.clear();

      // If we have a 'known' device, put it back in the list immediately
      if (widget.bluetoothState.connectedDevice != null) {
        _discoveredDevices.add(widget.bluetoothState.connectedDevice!);
      }

      _isScanning = true;
    });

    _scanSubscription = widget.bluetoothState.flutterReactiveBle.scanForDevices(
        withServices: [], scanMode: ScanMode.lowLatency).listen((device) {
      if (device.name.isEmpty) return;
      if (mounted) {
        setState(() {
          final index = _discoveredDevices.indexWhere((d) => d.id == device.id);
          if (index == -1) {
            _discoveredDevices.add(device);
          } else {
            _discoveredDevices[index] = device;
          }
        });
      }
    }, onError: (Object error) {
      // stopScan();
      _stopScanAndDisconnect();
    });

    scanTimer?.cancel();
    scanTimer =
        Timer(const Duration(seconds: 15), () => _stopScanAndDisconnect());
    //stopScan());
  }

  Future<void> _stopScanAndDisconnect() async {
    // Stop scan first
    await _scanSubscription.cancel();
    // _scanSubscription = null;

    scanTimer?.cancel();
    scanTimer = null;

    // Disconnect active BLE connection if exists
    final connectedDevice = widget.bluetoothState.connectedDevice;

    if (connectedDevice != null) {
      try {
        // await widget.bluetoothState.flutterReactiveBle
        //     .disconnectDevice(id: connectedDevice.id);
        debugPrint('device connected');
      } catch (e) {
        connectingDeviceId = '';
        debugPrint('Disconnect error: $e');
      }
    }

    if (mounted) {
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> stopScan() async {
    scanTimer?.cancel();

    await _scanSubscription.cancel();

    if (mounted) {
      setState(() {
        _isScanning = false;
      });
    }
  }

  onDisconnection() {
    setState(() {
      connectingDeviceId = '';
      // _discoveredDevices.clear();
    });
  }

  // Future<void> bluetoothAlert() async {
  //   await OptionDialog.show(
  //     context,
  //     title: 'bluetooth'.tr(),
  //     message: Text(
  //       'turnOnBluetooth'.tr(),
  //     ),
  //     typeDialog: 'alert',
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    // context.read<LanguageController>();
    // context.watch<LanguageController>();
    var device = OrientationHelper(context);

    return PopScope(
      canPop: true, //When false, blocks the current route from being popped.
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.whiteBg,
        appBar: CustomAppBar(
            title: 'bluetoothPageTitle'.tr(),
            bluetoothTap: false,
            onBackPressed: () {
              Navigator.pop(context);
            }),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: device.height() * 0.02),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[],
                  ),
                ),

                // --- Connected + discovered devices ---
                ValueListenableBuilder<bool>(
                  valueListenable: widget.bluetoothState.connected,
                  builder: (context, connected, _) {
                    final String? connectedId =
                        widget.bluetoothState.connectedDevice?.id;
                    final otherDevices = _discoveredDevices
                        .where((d) => d.id != connectedId)
                        .toList();

                    return Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (connected &&
                              widget.bluetoothState.connectedDevice !=
                                  null) ...[
                            Text(
                              'connectedDevice'.tr(),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                border: Border.all(color: AppColors.addBtn),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListTile(
                                dense: true, // Makes the tile smaller
                                leading: Icon(Icons.bluetooth_connected,
                                    color: AppColors.addBtn),
                                title: Text(
                                  widget.bluetoothState.connectedDevice!.name,
                                  style: TextStyle(
                                      color: AppColors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  widget.bluetoothState.connectedDevice!.id,
                                  style: TextStyle(
                                    color: AppColors.black,
                                  ),
                                ),
                                trailing: Text('connected'.tr(),
                                    style: TextStyle(
                                      color: AppColors.addBtn,
                                      fontSize: AppSettings.fontSizeMain,
                                    )),
                                onTap: () {
                                  disconnectDialog(
                                      context,
                                      widget.bluetoothState.connectedDevice!
                                          .name);
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'availableDevices'.tr(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 10),
                                  _isScanning && otherDevices.isNotEmpty
                                      ? const SizedBox(
                                          width: 15,
                                          height: 15,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ))
                                      : const SizedBox()
                                ],
                              ),
                              InkWell(
                                onTap: () {
                                  _startScan();
                                },
                                // onTap: _isScanning
                                //     ? () {}
                                //     : () {
                                //         _startScan();
                                //       },
                                highlightColor: AppColors.white,
                                child: Container(
                                  height: device.height() * 0.035,
                                  width: device.width() * 0.25,
                                  margin: const EdgeInsets.only(top: 7),
                                  decoration: BoxDecoration(
                                    color: AppColors.editBtn,
                                    // color: _isScanning
                                    //     ? AppColors.greyShade400
                                    //     : AppColors.editBtn,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.search,
                                          color: AppColors.white,
                                        ),
                                        Text(
                                          'scanDevice'.tr(),
                                          // _isScanning
                                          //     ? 'scanning'.tr()
                                          //     : 'scanDevice'.tr(),
                                          style: TextStyle(
                                            fontSize:
                                                AppSettings.fontSizeSubtitle,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          discoveredDeviceList(),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Display discovered devices
  Widget discoveredDeviceList() {
    double height = MediaQuery.of(context).size.height;
    final String? connectedId = widget.bluetoothState.connectedDevice?.id;
    final otherDevices =
        _discoveredDevices.where((d) => d.id != connectedId).toList();

    final availableDevices = _discoveredDevices.where((device) {
      return device.id != connectedId;
    }).toList();

    // If we are currently scanning and the list is still empty, show a big loader
    if (_isScanning && otherDevices.isEmpty) {
      return SizedBox(
        height: height * 0.7,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 10),
              Text('searchDevice'.tr()),
            ],
          ),
        ),
      );
    }

    // If we STOPPED scanning and still found nothing, show the "No Devices" message
    if (!_isScanning && otherDevices.isEmpty) {
      return SizedBox(
        height: height * 0.7,
        child: Center(
          child: bleStatus == BleStatus.ready
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('noDevicesDiscovered'.tr()),
                    InkWell(
                      child: Container(
                        height: height * 0.03,
                        width: height * 0.1,
                        margin: const EdgeInsets.only(top: 7),
                        decoration: BoxDecoration(
                          color: AppColors.editBtn,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(
                          child: Text(
                            'tryAgain'.tr(),
                            style: TextStyle(
                              fontSize: AppSettings.fontSizeMain,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                      onTap: () {
                        _startScan();
                      },
                    ),
                  ],
                )
              : Text('turnOnBluetooth'.tr()),
        ),
      );
    }

    return Column(
      children: [
        ...List.generate(availableDevices.length, (index) {
          var device = availableDevices[index];

          return Column(
            children: [
              Container(
                color: AppColors.greyShade200,
                child: ListTile(
                  dense: true, // Makes the tile smaller
                  leading: Icon(Icons.bluetooth, color: AppColors.greyShade700),
                  title: Text(
                    device.name.isNotEmpty ? device.name : 'unnamedDevice'.tr(),
                    style: TextStyle(
                        color: AppColors.black, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    device.id,
                    style: TextStyle(
                      color: AppColors.black,
                    ),
                  ),
                  trailing: connectingDeviceId == device.id
                      ? SizedBox(
                          height: height * 0.02,
                          width: height * 0.02,
                          child: CircularProgressIndicator(
                            color: AppColors.greyShade400,
                            strokeWidth: 3,
                          ),
                        )
                      : widget.bluetoothState.connectedDevice != null &&
                              widget.bluetoothState.connectedDevice!.id ==
                                  device.id
                          ? Icon(Icons.check, color: AppColors.successColor)
                          : null,
                  onTap: () {
                    connectDisconnectDevice(device);
                    // connectedTimer?.cancel();
                    // connectedTimer = Timer(const Duration(seconds: 30), () {
                    //   if (mounted && _isScanning) {
                    //     setState(() {
                    //       _scanSubscription.cancel();
                    //       setState(() => _isScanning = false);
                    //       Fluttertoast.showToast(
                    //           msg: 'failConnectBluetooth'.tr());
                    //     });
                    //   }
                    // });
                    // setState(() => connectingDeviceId = device.id);

                    // // Start connection and STOP scan to save resources
                    // _scanSubscription.cancel();
                    // setState(() => _isScanning = false);
                    // widget.bluetoothState.connectToDevice(device);
                  },
                ),
              ),
              // ONLY add divider if it is NOT the last item
              if (index != _discoveredDevices.length - 1)
                const Divider(height: 1, thickness: 1),
            ],
          );
        }),
      ],
    );
  }

  void connectDisconnectDevice(device) {
    var connectedDeviceId = widget.bluetoothState.connectedDevice;

    if (connectedDeviceId != null) {
      // prompt user a device is already connected
      showErrorToast('connectedDevicePrompt'.tr(), context);

      return;
    }

    // connectedTimer?.cancel();
    connectedTimer = Timer(const Duration(seconds: 10), () {
      if (mounted && _isScanning) {
        setState(() {
          _scanSubscription.cancel();
          setState(() => _isScanning = false);
          // Fluttertoast.showToast(msg: 'failConnectBluetooth'.tr());
          showErrorToast('failConnectBluetooth'.tr(), context);
        });
      }
    });
    setState(() => connectingDeviceId = device.id);

    // Start connection and STOP scan to save resources
    _scanSubscription.cancel();
    setState(() => _isScanning = false);

    widget.bluetoothState.connectToDevice(device);
  }

  Future<void> disconnectDialog(BuildContext context, String deviceName) async {
    // final device = OrientationHelper(context);
    await OptionDialog.show(context,
            title: '${'disconnect'.tr()}?',
            message: RichText(
              text: TextSpan(
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkGrey),
                children: [
                  TextSpan(
                    text: 'disconnectMsg'.tr(),
                  ),
                  // Item code
                  TextSpan(
                    text: deviceName,
                    style: TextStyle(
                        fontSize: AppSettings.fontSizeMain,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black),
                  ),
                ],
              ),
            ),
            typeDialog: 'delete',
            verticalPadding: 10)
        .then((value) async {
      if (value == true) {
        connectingDeviceId = '';
        widget.bluetoothState.disconnectDevice();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    _scanSubscription.cancel();
  }
}
