part of 'details_page.dart';

enum PageDirection {
  next,
  previous,
}

mixin UIOverlayMixin on ChangeNotifier {
  ValueNotifier<bool> get hideOverlay;

  void toggleOverlay() {
    hideOverlay.value = !hideOverlay.value;
    if (hideOverlay.value) {
      hideSystemStatus();
    } else {
      showSystemStatus();
    }
    notifyListeners();
  }

  // set overlay value
  void setHideOverlay(bool value) {
    hideOverlay.value = value;
    notifyListeners();
  }

  void restoreSystemStatus() {
    showSystemStatus();
  }
}

class DetailsPageController extends ChangeNotifier with UIOverlayMixin {
  DetailsPageController({
    bool swipeDownToDismiss = true,
    bool hideOverlay = false,
    int initialPage = 0,
  })  : _enableSwipeDownToDismiss = swipeDownToDismiss,
        currentPage = ValueNotifier(initialPage),
        _hideOverlay = ValueNotifier(hideOverlay);

  var _enableSwipeDownToDismiss = false;

  var _enablePageSwipe = true;
  final _slideshow = ValueNotifier<bool>(false);
  final _expanded = ValueNotifier<bool>(false);
  late final ValueNotifier<bool> _hideOverlay;

  bool get swipeDownToDismiss => _enableSwipeDownToDismiss;
  bool get pageSwipe => _enablePageSwipe;
  @override
  ValueNotifier<bool> get hideOverlay => _hideOverlay;
  ValueNotifier<bool> get slideshow => _slideshow;
  ValueNotifier<bool> get expanded => _expanded;

  // use stream event to change to next page or previous page
  final StreamController<PageDirection> _pageController =
      StreamController<PageDirection>.broadcast();

  Stream<PageDirection> get pageStream => _pageController.stream;

  late final ValueNotifier<int> currentPage;

  bool get blockSwipe => !pageSwipe || !swipeDownToDismiss;

  void nextPage() {
    _pageController.add(PageDirection.next);
  }

  void previousPage() {
    _pageController.add(PageDirection.previous);
  }

  void startSlideshow() {
    _slideshow.value = true;
    disablePageSwipe();
    disableSwipeDownToDismiss();
    if (!_hideOverlay.value) setHideOverlay(true);
    hideSystemStatus();
    notifyListeners();
  }

  void stopSlideshow() {
    _slideshow.value = false;
    enablePageSwipe();
    enableSwipeDownToDismiss();
    setHideOverlay(false);
    showSystemStatus();
    notifyListeners();
  }

  void enableSwipeDownToDismiss() {
    _enableSwipeDownToDismiss = true;
    notifyListeners();
  }

  void disableSwipeDownToDismiss() {
    _enableSwipeDownToDismiss = false;
    notifyListeners();
  }

  void enablePageSwipe() {
    _enablePageSwipe = true;
    notifyListeners();
  }

  void disablePageSwipe() {
    _enablePageSwipe = false;
    notifyListeners();
  }

  void setEnablePageSwipe(bool value) {
    _enablePageSwipe = value;
    notifyListeners();
  }

  void setExpanded(bool value) {
    _expanded.value = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _pageController.close();
    super.dispose();
  }
}
