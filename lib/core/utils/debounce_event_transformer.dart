import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

/// A bloc [EventTransformer] that waits for [duration] of silence on the
/// event stream before letting the latest event through to [mapper].
EventTransformer<E> debounce<E>(Duration duration) {
  return (events, mapper) {
    final controller = StreamController<E>();
    Timer? timer;
    final subscription = events.listen(
      (event) {
        timer?.cancel();
        timer = Timer(duration, () => controller.add(event));
      },
      onDone: controller.close,
      onError: controller.addError,
    );
    controller.onCancel = () {
      timer?.cancel();
      subscription.cancel();
    };
    return controller.stream.asyncExpand(mapper);
  };
}
