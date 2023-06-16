import 'package:flutter/material.dart'
    show
        AppBar,
        BuildContext,
        Colors,
        EdgeInsets,
        Expanded,
        GlobalKey,
        Icon,
        IconButton,
        Icons,
        InkWell,
        Key,
        MainAxisAlignment,
        MediaQuery,
        Padding,
        PopupMenuButton,
        PopupMenuItem,
        Row,
        Scaffold,
        ScaffoldState,
        SingleChildScrollView,
        SizedBox,
        StatelessWidget,
        Tab,
        TabBar,
        TabBarView,
        Text,
        TextStyle,
        Visibility,
        Widget,
        debugPrint,
        kToolbarHeight;
import 'package:ble_esp32/app/controllers/device_controller.dart'
    show DeviceController;
import 'package:ble_esp32/app/helper/popup_dialogs.dart' show showConfirmDialog;
import 'package:ble_esp32/app/views/connection_view.dart' show ConnectionView;
import 'package:get/get.dart';
import 'package:ble_esp32/main.dart' show ctrl;
import 'package:ble_esp32/app/views/data_logs_view.dart' show DataLogs;
import 'package:ble_esp32/app/views/devices_view.dart' show DevicesView;
import 'temperature_view.dart' show TemperatureView;

final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

enum DevicePopupMenuItem { newDevice, saveDevice, loadDevice }

class MainView extends StatelessWidget {
  const MainView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text("Flutter Bluetooth"),
        backgroundColor: Colors.deepPurple,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14.0, top: 10, bottom: 6),
            child: Obx(() {
              return Visibility(
                  visible: (ctrl.selectedTabIndex.value == 1 &&
                          ctrl.logs.value.isNotEmpty) ||
                      ctrl.selectedTabIndex.value == 2,
                  child: ctrl.selectedTabIndex.value == 1
                      ? Row(
                          children: [
                            // switch logs view as chat view or standard view
                            IconButton(
                                onPressed: () {
                                  ctrl.isLogAsChatView.value =
                                      !ctrl.isLogAsChatView.value;
                                },
                                icon: Icon(ctrl.isLogAsChatView.isTrue
                                    ? Icons.table_rows_rounded
                                    : Icons.chat)),

                            const SizedBox(
                              width: 40,
                            ),

                            InkWell(
                              onTap: () {
                                showConfirmDialog(
                                    context: context,
                                    title: 'Delete logs confirm',
                                    text: 'Delete all log?',
                                    onOkPressed: deleteLogs);
                              },
                              child: const Icon(Icons.delete),
                            ),
                          ],
                        )
                      :
                      // OutlinedButton(
                      //     onPressed: () {
                      //       const DevicesView().createNewDevice(context);
                      //     },
                      //     style: buildButtonStyle(borderColor: Colors.grey, splashColor: Colors.yellow),
                      //     child: const Text('New Device', style: TextStyle(color: Colors.white),)
                      // ),
                      PopupMenuButton<DevicePopupMenuItem>(
                          onSelected: (DevicePopupMenuItem item) {
                          if (item == DevicePopupMenuItem.newDevice) {
                            const DevicesView().createNewDevice(context);
                          } else if (item == DevicePopupMenuItem.saveDevice) {
                            if (DeviceController.deviceList.isNotEmpty) {
                              DeviceController.saveDeviceListIntoStorage();
                            } else {
                              null;
                            }
                          } else {
                            DeviceController.loadDeviceListFromStorage(
                                isLoadFromInitApp: false);
                          }
                        }, itemBuilder: (BuildContext context) {
                          return [
                            const PopupMenuItem<DevicePopupMenuItem>(
                              value: DevicePopupMenuItem.newDevice,
                              child: Row(
                                children: [
                                  Text('New Device'),
                                  Expanded(
                                      child: SizedBox(
                                    width: 10,
                                  )),
                                  Icon(Icons.add_rounded,
                                      size: 20.0, color: Colors.black)
                                ],
                              ),
                            ),
                            PopupMenuItem<DevicePopupMenuItem>(
                              value: DevicePopupMenuItem.saveDevice,
                              child: Row(
                                children: [
                                  Text(
                                    'Save Device',
                                    style: TextStyle(
                                        color: DeviceController
                                                .deviceList.isNotEmpty
                                            ? Colors.black
                                            : Colors.grey),
                                  ),
                                  const Expanded(
                                      child: SizedBox(
                                    width: 10,
                                  )),
                                  Icon(Icons.save_alt_outlined,
                                      size: 20.0,
                                      color:
                                          DeviceController.deviceList.isNotEmpty
                                              ? Colors.black
                                              : Colors.grey)
                                ],
                              ),
                            ),
                            const PopupMenuItem<DevicePopupMenuItem>(
                              value: DevicePopupMenuItem.loadDevice,
                              child: Row(
                                children: [
                                  Text('Load Device'),
                                  Expanded(
                                      child: SizedBox(
                                    width: 10,
                                  )),
                                  Icon(
                                    Icons.upload_outlined,
                                    size: 20.0,
                                    color: Colors.black,
                                  )
                                ],
                              ),
                            ),
                          ];
                        }));
            }),
          )
        ],
        bottom: TabBar(
          controller: ctrl.tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(
                icon: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bluetooth),
                // SizedBox(width: 10,),
                Text('Connection')
              ],
            )),
            Tab(
                icon: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.terminal),
                SizedBox(
                  width: 10,
                ),
                Text('Data Logs')
              ],
            )),
            Tab(
                icon: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.list_alt_outlined),
                SizedBox(
                  width: 4,
                ),
                Text('Device List')
              ],
            )),
            Tab(
                icon: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.list_alt_outlined),
                SizedBox(
                  width: 4,
                ),
                Text('Temperature')
              ],
            )),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height -
              AppBar().preferredSize.height -
              kToolbarHeight * 1.2,
          child: TabBarView(
            controller: ctrl.tabController,
            children: const [
              // bluetooth connection tab
              ConnectionView(),

              // Data logs tab
              DataLogs(),

              // device list tab
              DevicesView(),

              // device list tab
              TemperatureView(),
            ],
          ),
        ),
      ),
    );
  }

  void deleteLogs() {
    Get.back();
    ctrl.logs.value.clear();
    ctrl.logs.refresh();
    debugPrint('[main_view] Logs deleted');
  }
}
