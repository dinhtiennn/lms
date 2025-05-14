import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import 'package:lms/src/presentation/presentation.dart';

class NavigationTeacherViewModel extends BaseViewModel {
  final PersistentTabController controller = PersistentTabController(initialIndex: 0);

  init() async {}

  void setIndex(int index) {
    controller.index = index;
  }
}
