import 'package:kael_file_browser/util.dart';

class Movement {
  // TODO validate src and dst
  Movement({
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
    Util.moveFile(src, dst);
    done = true;
  }

  undo() {
    if (dst.isEmpty || src.isEmpty) {
      return;
    }
    Util.moveFile(dst, src);
    done = false;
  }
}
