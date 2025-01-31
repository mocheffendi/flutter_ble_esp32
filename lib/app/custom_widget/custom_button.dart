import 'package:flutter/material.dart'
    show
        BuildContext,
        Color,
        Colors,
        Key,
        OutlinedButton,
        StatelessWidget,
        VoidCallback,
        Widget,
        debugPrint;
import 'package:ble_esp32/app/controllers/device_controller.dart'
    show DeviceController;
import 'package:ble_esp32/app/helper/widget_helper.dart' show buildButtonStyle;

class MyCustomButton extends StatelessWidget {
  final VoidCallback? onPressedAction;
  // final void Function()? onPressedAction;
  final String? commandTitle;
  final Widget customWidget;
  final Color? borderColor;
  final bool? isCircleButton;
  final double? radiusSize;
  final double? buttonWidth;
  const MyCustomButton(
      {Key? key,
      required this.customWidget,
      required this.onPressedAction,
      this.borderColor,
      this.commandTitle,
      this.isCircleButton,
      this.radiusSize,
      this.buttonWidth})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
        onPressed: () {
          if (commandTitle != null) {
            debugPrint('');
            debugPrint('[widget_helper]commandTitle: $commandTitle');
            DeviceController.selectedTitle = commandTitle!;
          }

          onPressedAction?.call();

          if (DeviceController.isEditDevice ||
              DeviceController.isInsertNewDevice) {
            DeviceController.refreshSaveDeviceButtonState();
          }
          // onPressedAction;
        },
        style: buildButtonStyle(
            borderColor: borderColor ?? Colors.grey,
            isCircleButton: isCircleButton ?? true,
            radiusSize: radiusSize,
            buttonWidth: buttonWidth),
        child: customWidget);
  }
}
