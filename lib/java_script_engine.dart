import 'dart:ffi';
import 'dart:io' show Platform;
import 'package:ffi/ffi.dart' as ffi;
import 'package:path/path.dart' as p;             // Add this import

import 'java_script_engine_bindings_generated.dart';

const String _libName = 'java_script_engine';

final DynamicLibrary _dylib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    // Add from here...
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return DynamicLibrary.open('build/macos/Build/Products/Debug'
          '/$_libName/$_libName.framework/$_libName');
    }
    // ...to here.
    return DynamicLibrary.open('$_libName.framework/$_libName');
  }
  if (Platform.isAndroid || Platform.isLinux) {
    // Add from here...
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return DynamicLibrary.open(
          'build/linux/x64/debug/bundle/lib/lib$_libName.so');
    }
    // ...to here.
    return DynamicLibrary.open('lib$_libName.so');
  }
  if (Platform.isWindows) {
    // Add from here...
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return DynamicLibrary.open(p.canonicalize(
          p.join(r'build\windows\runner\Debug', '$_libName.dll')));
    }
    // ...to here.
    return DynamicLibrary.open('$_libName.dll');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

final JavaScriptEngineBindings _bindings = JavaScriptEngineBindings(_dylib);

class Duktape {
  Duktape() {
    ctx =
        _bindings.duk_create_heap(nullptr, nullptr, nullptr, nullptr, nullptr);
  }

  // Modify this function
  String evalString(String jsCode) {
    var nativeUtf8 = jsCode.toNativeUtf8();
    final evalResult = _bindings.duk_eval_raw(
        ctx,
        nativeUtf8.cast<Char>(),
        0,
        0 |
        DUK_COMPILE_EVAL |
        DUK_COMPILE_SAFE |
        DUK_COMPILE_NOSOURCE |
        DUK_COMPILE_STRLEN |
        DUK_COMPILE_NOFILENAME);
    ffi.malloc.free(nativeUtf8);

    if (evalResult != 0) {
      throw _retrieveTopOfStackAsString();
    }

    return _retrieveTopOfStackAsString();
  }

  // Add this function
  String _retrieveTopOfStackAsString() {
    Pointer<Size> outLengthPtr = ffi.calloc<Size>();
    final errorStrPtr = _bindings.duk_safe_to_lstring(ctx, -1, outLengthPtr as Pointer<duk_size_t>);
    final returnVal =
    errorStrPtr.cast<ffi.Utf8>().toDartString(length: outLengthPtr.value);
    ffi.calloc.free(outLengthPtr);
    return returnVal;
  }

  void dispose() {
    _bindings.duk_destroy_heap(ctx);
    ctx = nullptr;
  }

  late Pointer<duk_hthread> ctx;
}