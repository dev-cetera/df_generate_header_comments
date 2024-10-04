// The use of this source code is governed by the LICENSE file located in this
// project's root directory.

import 'package:df_generate_header_comments/df_generate_header_comments.dart';
import 'package:df_log/df_log.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

void main(List<String> args) async {
  DebugLog.debugOnly = false;
  await generateCommentHeadersApp(args);
}
