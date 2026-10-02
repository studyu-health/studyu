import 'package:web/web.dart' as web;

bool? platformIsDeviceOnline() => web.window.navigator.onLine;
