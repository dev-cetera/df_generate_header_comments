//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// 🇽🇾🇿 & Dev
//
// Licencing details are in the LICENSE file in the root directory.
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

import 'package:df_gen_core/df_gen_core.dart';
import 'package:df_log/df_log.dart';
import 'package:path/path.dart' as p;

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

Future<void> generateCommentHeaders({
  Set<String> rootDirPaths = const {},
  Set<String> subDirPaths = const {},
  Set<String> pathPatterns = const {},
  required String templateFilePath,
}) async {
  // Notify start.
  debugLogStart('Starting generator. Please wait...');

  // Explore all source paths.
  final sourceFileExporer = PathExplorer(
    dirPathGroups: {
      CombinedPaths(
        rootDirPaths,
        subPaths: subDirPaths,
        pathPatterns: pathPatterns,
      ),
    },
  );
  final sourceFileExplorerResults = await sourceFileExporer.explore();

  final template = extractCodeFromMarkdown(
    await loadFileFromPathOrUrl(templateFilePath),
  );

  // ---------------------------------------------------------------------------

  final fileResults = sourceFileExplorerResults.filePathResults;

  for (final fileResult in fileResults) {
    await _generateForFile(fileResult, template);
  }

  Here().debugLogStop('Done!');
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

Future<void> _generateForFile(FilePathExplorerResult fileResult, String template) async {
  final filePath = fileResult.path;
  final commentStarter = langFileCommentStarters[p.extension(filePath).toLowerCase()] ?? '//';
  final lines = (await readFileAsLines(filePath))!;
  if (lines.isNotEmpty) {
    for (var n = 0; n < lines.length; n++) {
      final line = lines[n].trim();
      if (line.isEmpty || !line.startsWith(commentStarter)) {
        final withoutHeader = lines.sublist(n).join('\n');
        final withHeader = '${template.trim()}\n\n${withoutHeader.trim()}';
        await writeFile(filePath, withHeader);
        break;
      }
    }
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

final langFileCommentStarters = {
  '.ada': '--', // Ada
  '.awk': '#', // AWK
  '.bat': 'REM ', // Batch
  '.cfg': '#', // Configuration files
  '.clj': ';', // Clojure
  '.cob': '*>', // COBOL
  '.erl': '%', // Erlang
  '.exs': '#', // Elixir
  '.f90': '!', // Fortran
  '.fish': '#', // Fish Shell
  '.hs': '--', // Haskell
  '.ini': ';', // INI configuration files
  '.jsonc': '//', // JSONC
  '.lisp': ';', // Lisp
  '.lua': '--', // Lua
  '.m': '%', // MATLAB and Octave
  '.pl': '#', // Perl
  '.ps1': '#', // PowerShell
  '.py': '#', // Python
  '.r': '#', // R
  '.rb': '#', // Ruby
  '.rst': '..', // reStructuredText, comment blocks
  '.scm': ';', // Scheme
  '.sed': '#', // SED
  '.sh': '#', // Bash
  '.sql': '--', // SQL
  '.tcl': '#', // TCL
  '.tex': '%', // LaTeX documents
  '.vbs': "'", // VBScript
  '.vim': '"', // Vim script
  '.yaml': '#', // YAML
  '.zsh': '#', // Zsh
}.map((k, v) => MapEntry(k.toLowerCase(), v));
