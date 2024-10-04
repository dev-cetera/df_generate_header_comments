//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// Dart/Flutter (DF) Packages by DevCetra.com & contributors. The use of this
// source code is governed by an MIT-style license described in the LICENSE
// file located in this project's root directory.
//
// See: https://opensource.org/license/mit
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
    categorizedPathPatterns: [
      const CategorizedPattern(
        pattern: r'^(?!.*\.g\.dart$).*\.dart$',
        category: _Languages.DART,
      ),
      const CategorizedPattern(
        pattern: r'^(?!.*\.g\.js$).*\.js$',
        category: _Languages.JS,
      ),
      const CategorizedPattern(
        pattern: r'^(?!.*\.g\.jsonc$).*\.jsonc$',
        category: _Languages.JSONC,
      ),
      const CategorizedPattern(
        pattern: r'^(?!.*\.g\.yaml$).*\.yaml$',
        category: _Languages.YAML,
      ),
      const CategorizedPattern(
        pattern: r'^(?!.*\.g\.yml$).*\.yml$',
        category: _Languages.YML,
      ),
      const CategorizedPattern(
        pattern: r'^(?!.*\.g\.ts$).*\.ts$',
        category: _Languages.TS,
      ),
      const CategorizedPattern(
        pattern: r'^(?!.*\.g\.ps1$).*\.ps1$',
        category: _Languages.PS1,
      ),
    ],
  );
  final sourceFileExplorerResults = await sourceFileExporer.explore();

  final templateLines = extractCodeFromMarkdown(
    await loadFileFromPathOrUrl(templateFilePath),
  ).trim().split('\n');

  // ---------------------------------------------------------------------------

  final fileResults = sourceFileExplorerResults.filePathResults;

  for (final fileResult in fileResults) {
    await _generateForFile(fileResult, templateLines);
  }

  // ---------------------------------------------------------------------------

  // Notify end.
  debugLogStop('Done!');
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

Future<void> _generateForFile(
  FilePathExplorerResult fileResult,
  List<String> templateLines,
) async {
  if (!_Languages.values.contains(fileResult.category)) return;

  final filePath = fileResult.path;

  final commentStarter =
      langFileCommentStarters[p.extension(filePath).toLowerCase()] ?? '//';
  final lines = (await readFileAsLines(filePath)) ?? [];

  if (lines.isNotEmpty) {
    // Replace leading '//' in all template lines with the comment starter
    templateLines = templateLines.map((line) {
      if (line.trim().startsWith('//')) {
        return commentStarter + line.substring(2); // Replace leading // only
      }
      return line; // Return the line unchanged if it doesn't start with //
    }).toList();

    for (var n = 0; n < lines.length; n++) {
      final line = lines[n].trim();
      if (line.isEmpty || !line.startsWith(commentStarter)) {
        final withoutHeader = lines.sublist(n).join('\n');
        final withHeader =
            '${templateLines.join('\n')}\n\n${withoutHeader.trimLeft()}';
        await writeFile(filePath, withHeader);
        break;
      }
    }
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

enum _Languages {
  DART,
  JS,
  JSONC,
  PS1,
  TS,
  YAML,
  YML,
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

final langFileCommentStarters = {
  '.ada': '--', // Ada
  '.awk': '##', // AWK
  '.bat': 'REM ', // Batch
  '.cfg': '##', // Configuration files
  '.clj': ';', // Clojure
  '.cob': '*>', // COBOL
  '.dart': '//', // Erlang
  '.erl': '%', // Erlang
  '.exs': '##', // Elixir
  '.f90': '!', // Fortran
  '.fish': '##', // Fish Shell
  '.hs': '--', // Haskell
  '.ini': ';', // INI configuration files
  '.jsonc': '//', // JSONC
  '.lisp': ';', // Lisp
  '.lua': '--', // Lua
  '.m': '%', // MATLAB and Octave
  '.pl': '##', // Perl
  '.ps1': '##', // PowerShell
  '.py': '##', // Python
  '.r': '##', // R
  '.rb': '##', // Ruby
  '.rst': '..', // reStructuredText, comment blocks
  '.scm': ';', // Scheme
  '.sed': '##', // SED
  '.sh': '##', // Bash
  '.sql': '--', // SQL
  '.tcl': '##', // TCL
  '.tex': '%', // LaTeX documents
  '.vbs': "'", // VBScript
  '.vim': '"', // Vim script
  '.yaml': '##', // YAML
  '.yml': '##', // YAML
  '.zsh': '##', // Zsh
}.map((k, v) => MapEntry(k.toLowerCase(), v));
