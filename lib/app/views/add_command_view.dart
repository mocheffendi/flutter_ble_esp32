import 'package:flutter/material.dart'
    show
        BuildContext,
        Column,
        Flexible,
        Key,
        MainAxisAlignment,
        Navigator,
        Row,
        SizedBox,
        StatelessWidget,
        Text,
        Widget;
import 'package:ble_esp32/app/controllers/device_controller.dart'
    show DeviceController;
import 'package:get/get.dart';
import 'package:ble_esp32/app/controllers/command_controller.dart'
    show CommandController;
import 'package:ble_esp32/app/custom_widget/custom_button.dart'
    show MyCustomButton;
import 'package:ble_esp32/app/helper/widget_helper.dart' show buildTextField;

class CommandView extends StatelessWidget {
  const CommandView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: commandItems(context),
    );
  }

  List<Widget> commandItems(BuildContext context) {
    List<Widget> actionList = [
      const SizedBox(height: 10),
      Obx(() {
        return buildTextField(
            title: 'Command Title',
            commandText: CommandController.commandTitleCtrl.text,
            errorText: CommandController.commandTitleErrorText.value,
            commandTextController: CommandController.commandTitleCtrl,
            onChanged: CommandController.validateCommmandInput);
      }),
      Obx(() {
        return SizedBox(
            height: CommandController.commandTitleErrorText.isEmpty ? 0 : 20);
      }),
      // buildTextField(labelText: 'Command Description', textController: Controller.newDeviceCont),
      // const SizedBox(height: 20),
      Obx(() {
        return buildTextField(
            title: 'Command',
            commandText: CommandController.commandCtrl.text,
            errorText: CommandController.commandErrorText.value,
            commandTextController: CommandController.commandCtrl,
            onChanged: CommandController.validateCommmandInput);
      }),

      Obx(() {
        return SizedBox(
            height: CommandController.commandErrorText.isEmpty ? 0 : 20);
      }),

      buildTextField(
          title: 'Log Text',
          commandTextController: CommandController.commandLogText,
          commandText: CommandController.commandLogText.text),
      const SizedBox(height: 10),

      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: MyCustomButton(
                customWidget: const Text('Cancel'),
                isCircleButton: false,
                buttonWidth: 100,
                onPressedAction: () {
                  CommandController.isEditCommand.value = false;
                  Navigator.pop(context);
                }),
          ),
          const SizedBox(
            width: 20,
          ),
          Flexible(
            child: MyCustomButton(
                customWidget: const Text('Save'),
                isCircleButton: false,
                buttonWidth: 100,
                onPressedAction: () {
                  CommandController.validateCommmandInput();

                  if (CommandController.isInputCommandValid.isTrue) {
                    CommandController.saveNewCommand();
                    DeviceController.refreshNewCommandButtonState();

                    if (CommandController.isEditCommand.isTrue) {
                      CommandController.isEditCommand.value = false;
                    }
                    Navigator.pop(context);
                  }
                }),
          ),
        ],
      )
    ];

    return actionList;
  }
}
