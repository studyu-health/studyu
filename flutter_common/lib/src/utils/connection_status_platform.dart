import 'package:studyu_flutter_common/src/utils/connection_status_platform_stub.dart'
    if (dart.library.html) 'package:studyu_flutter_common/src/utils/connection_status_platform_web.dart';

bool? isDeviceOnline() => platformIsDeviceOnline();
