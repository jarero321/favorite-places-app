import 'package:flutter/widgets.dart';

import 'viewmodel/places_view_model.dart';

class PlacesScope extends InheritedNotifier<PlacesViewModel> {
  const PlacesScope({
    super.key,
    required PlacesViewModel viewModel,
    required super.child,
  }) : super(notifier: viewModel);

  // Subscribes the calling widget to rebuilds when the VM notifies.
  static PlacesViewModel of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<PlacesScope>();
    assert(scope != null, 'PlacesScope.of() called with no PlacesScope ancestor');
    return scope!.notifier!;
  }

  // Read-only access — does NOT subscribe. Use inside callbacks (onPressed, etc.).
  static PlacesViewModel read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<PlacesScope>();
    assert(scope != null, 'PlacesScope.read() called with no PlacesScope ancestor');
    return scope!.notifier!;
  }
}
