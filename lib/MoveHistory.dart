import 'package:kael_file_browser/util.dart';

class MoveHistory {
  // TODO validate src and dst
  MoveHistory({
    required this.src,
    required this.dst,
  });
  String src = "";
  String dst = "";
  bool done = false;

  doMove() {
    if (done || dst.isEmpty || src.isEmpty) {
      return;
    }
    String errMsg = Util.moveFile(src, dst);
    if (errMsg.isEmpty) {
      done = true;
    }
    return errMsg;
  }

  undo() {
    if (dst.isEmpty || src.isEmpty) {
      return;
    }
    String errMsg = Util.moveFile(dst, src);
    if (errMsg.isEmpty) {
      done = false;
    }
    return errMsg;
  }
}
