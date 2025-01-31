import 'package:flutter/material.dart'
    show
        BorderRadius,
        BorderSide,
        BuildContext,
        Card,
        Center,
        Column,
        EdgeInsets,
        ElevatedButton,
        Expanded,
        Icon,
        Icons,
        Key,
        ListView,
        Navigator,
        Padding,
        PopupMenuButton,
        PopupMenuItem,
        RoundedRectangleBorder,
        Row,
        SizedBox,
        StatelessWidget,
        Text,
        TextStyle,
        Widget,
        debugPrint,
        showModalBottomSheet;
import 'package:ble_esp32/app/controllers/device_controller.dart'
    show DeviceController;
import 'package:ble_esp32/app/helper/popup_dialogs.dart' show showConfirmDialog;
import 'package:get/get.dart';
import 'package:ble_esp32/bluetooth_dart.dart' show BluetoothData;
import 'package:ble_esp32/main.dart' show ctrl;
import 'package:ble_esp32/utils.dart' show SourceId, showGetxSnackbar;
import 'package:ble_esp32/app/constant/constant.dart' show colors;
import 'package:ble_esp32/app/views/add_device_view.dart' show AddDeviceView;

enum PopupItems { edit, delete }

class DevicesView extends StatelessWidget {
  const DevicesView({Key? key}) : super(key: key);

  void deleteDevice() {
    // Get.back();
    Navigator.pop(Get.context!);
    String deviceName =
        DeviceController.deviceList[DeviceController.deviceIndex].deviceName;
    DeviceController.deviceList.removeAt(DeviceController.deviceIndex);
    ctrl.refreshLogs(text: 'Device "$deviceName" deleted');
    // showSnackBar('Device deleted');
    showGetxSnackbar('Device deleted', 'Device "$deviceName" deleted');
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return DeviceController.deviceList.isNotEmpty
          ? ListView.builder(
              itemCount: DeviceController.deviceList.length,
              itemBuilder: (BuildContext context, int index) {
                debugPrint('[device_view] rebuilding listview');

                return buildDeviceContainer(
                    context: context,
                    deviceName: DeviceController.deviceList[index].deviceName,
                    status: DeviceController.deviceList[index].status,
                    commandToTurnOn: DeviceController
                        .deviceList[index].commandList[0].command,
                    commandToTurnOff: DeviceController
                        .deviceList[index].commandList[1].command,
                    deviceIndex: index);
              })
          : const Center(
              child: Text(
              'No device found',
              style: TextStyle(fontSize: 22),
            ));
    });
  }

  void editSelectedDevice(BuildContext context) {
    DeviceController.editDevice();

    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return const AddDeviceView(title: 'Edit device');
        }).whenComplete(() {
      debugPrint('');
      debugPrint('[device_view] show modal bottom sheet closed (edit device)');
      debugPrint(
          '[device_view] DeviceController.isSaveDeviceBtnClicked: ${DeviceController.isSaveDeviceBtnClicked}');
      // jika show modal bottom sheet closed, cek apakah ditutup karena tombol save device di klik atau bukan
      // jika bukan karena tombol save di klik, maka kembalikan data device yang lama karena device yang diedit tidak disimpan
      // DeviceController.currentDevice = DeviceController.deviceList[DeviceController.deviceIndex];
      // DeviceController.currentDevice = DeviceController.deviceList[0];
      if (DeviceController.isSaveDeviceBtnClicked == false
          // &&
          // (
          //     DeviceController.currentDevice?.commandList.length != DeviceController.oldDeviceData['oldDevice']['command_list'].length
          //     || DeviceController.deviceNameController.text != DeviceController.oldDeviceData['oldDevice']['device_name']
          // )
          ) {
        debugPrint('[device_view] old device rolled back');
        DeviceController.deviceList[DeviceController.deviceIndex].commandList =
            DeviceController.oldDeviceData['oldDevice']['commandList'];
        // DeviceController.deviceList[DeviceController.deviceIndex].commandMenuList!.clear();
        // DeviceController.deviceList[DeviceController.deviceIndex].commandMenuList = DeviceController.oldDeviceData['oldDevice']['commandMenuList'];
        ctrl.refreshLogs(
            text:
                'Device "${DeviceController.deviceList[DeviceController.deviceIndex].deviceName}" editing canceled');
        // showSnackBar('Device "${DeviceController.deviceList[DeviceController.deviceIndex].deviceName}" editing canceled');
        showGetxSnackbar('Cancel to edit',
            'Device "${DeviceController.deviceList[DeviceController.deviceIndex].deviceName}" editing canceled');
      }
    });
  }

  void createNewDevice(BuildContext context) {
    DeviceController.createNewDevice();

    // add new device
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),

        // to make bottom sheet move up when keyboard active if the keyboard hover of textfield
        // reference: https://stackoverflow.com/a/59005853
        // - wrap column with SingleChildScrollView
        // - wrap SingleChildScrollView with Padding --> padding: MediaQuery.of(context).viewInsets,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return const AddDeviceView(title: 'Add new device');
        }).whenComplete(() {
      debugPrint(
          '[device_view] show modal bottom sheet closed (insert new device)');
      // jika show modal bottom sheet closed, cek apakah ditutup karena tombol save device di klik atau bukan
      // jika bukan karena tombol save di klik, maka hapus device yang baru dibuat (jika ada)
      // if (DeviceController.isSaveDeviceBtnClicked == false && DeviceController.deviceList.length > DeviceController.deviceCount) {
      //   DeviceController.deviceList.removeAt(DeviceController.deviceList.length - 1);
      // }
    });
  }

  buildDeviceContainer(
      {required String deviceName,
      required bool status,
      required String commandToTurnOn,
      required String commandToTurnOff,
      required int deviceIndex,
      required BuildContext context}) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            // color: BluetoothData.instance.deviceState == 0
            //     ? colors['neutralBorderColor']!
            //     : BluetoothData.instance.deviceState == 1
            //     ? colors['onBorderColor']!
            //     : colors['offBorderColor']!,
            color: status
                ? colors['onBorderColor']!
                : colors['neutralBorderColor']!,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(4.0),
        ),
        // elevation: BluetoothData.instance.deviceState == 0 ? 4 : 0,
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      deviceName,
                      style: TextStyle(
                          fontSize: 20,
                          // color: BluetoothData.instance.deviceState == 0
                          //     ? colors['neutralTextColor']
                          //     : BluetoothData.instance.deviceState == 1
                          //     ? colors['onTextColor']
                          //     : colors['offTextColor'],
                          color: colors['neutralTextColor']!),
                    ),
                  ),

                  // to turned on button
                  ElevatedButton(
                    onPressed: () {
                      debugPrint(
                          '[devices_view] To turn On Command: $commandToTurnOn');

                      // jika log text tidak kosong, tampilkan log di data logs view
                      if (DeviceController.deviceList[deviceIndex]
                          .commandList[0].logText.isNotEmpty) {
                        ctrl.refreshLogs(
                            text: DeviceController
                                .deviceList[deviceIndex].commandList[0].logText,
                            sourceId: SourceId.hostId);
                      }

                      if (ctrl.isConnected.isTrue) {
                        BluetoothData.instance
                            .sendMessageToBluetooth(commandToTurnOn, false);
                        DeviceController.deviceList[deviceIndex].status = true;
                        DeviceController.deviceList.refresh();
                      }
                    },
                    child: const Text("ON"),
                  ),
                  const SizedBox(
                    width: 10,
                  ),

                  // to turned off button
                  ElevatedButton(
                    // onPressed: _connected
                    onPressed: () {
                      debugPrint(
                          '[devices_view] To turn Off Command: $commandToTurnOff');

                      if (DeviceController.deviceList[deviceIndex]
                          .commandList[1].logText.isNotEmpty) {
                        ctrl.refreshLogs(
                            text: DeviceController
                                .deviceList[deviceIndex].commandList[1].logText,
                            sourceId: SourceId.hostId);
                      }

                      // if (ctrl.isConnected.isTrue) {
                      BluetoothData.instance
                          .sendMessageToBluetooth(commandToTurnOff, false);
                      DeviceController.deviceList[deviceIndex].status = false;
                      DeviceController.deviceList.refresh();
                      // }
                    },
                    child: const Text("OFF"),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  PopupMenuButton<PopupItems>(onSelected: (PopupItems item) {
                    DeviceController.deviceIndex = DeviceController.deviceList
                        .indexWhere((dev) => dev.deviceName == deviceName);

                    if (item == PopupItems.edit) {
                      editSelectedDevice(context);
                    } else {
                      // delete the selected device
                      showConfirmDialog(
                        context: context,
                        title: 'Delete confirm',
                        text: 'Delete current device ($deviceName)?',
                        onOkPressed: deleteDevice,
                      );
                    }
                  }, itemBuilder: (BuildContext context) {
                    return [
                      const PopupMenuItem<PopupItems>(
                        value: PopupItems.edit,
                        child: Row(
                          children: [
                            Text('Edit'),
                            Expanded(
                                child: SizedBox(
                              width: 10,
                            )),
                            Icon(
                              Icons.edit,
                              size: 20.0,
                            )
                          ],
                        ),
                      ),
                      const PopupMenuItem<PopupItems>(
                        value: PopupItems.delete,
                        child: Row(
                          children: [
                            Text('Delete'),
                            Expanded(
                                child: SizedBox(
                              width: 10,
                            )),
                            Icon(
                              Icons.delete,
                              size: 20.0,
                            )
                          ],
                        ),
                      ),
                    ];
                  })
                ],
              ),
              // Text(description)
            ],
          ),
        ),
      ),
    );
  }
}
