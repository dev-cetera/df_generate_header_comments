//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// Dart/Flutter (DF) Packages by dev-cetera.com & contributors. The use of this
// source code is governed by an MIT-style license described in the LICENSE
// file located in this project's root directory.
//
// See: https://opensource.org/license/mit
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

import 'package:df_gen_core/df_gen_core.dart';

import 'package:path/path.dart' as p;

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

Future<void> genHeaderComments(
  List<String> args, {
  required String defaultTemplate,
}) async {
  final parser = CliParser(
    title: 'dev-cetera.com/df/tools',
    description:
        'A tool for generating header comments for your source files. Ignores files that starts with underscores.',
    example: 'gen-header-comments -i .',
    params: [
      DefaultFlags.HELP.flag.copyWith(
        negatable: true,
      ),
      DefaultOptions.INPUT_PATH.option.copyWith(
        defaultsTo: FileSystemUtility.i.currentDir,
      ),
      DefaultOptions.TEMPLATE_PATH_OR_URL.option.copyWith(
        defaultsTo: defaultTemplate,
      ),
    ],
  );

  // ---------------------------------------------------------------------------

  final (argResults, argParser) = parser.parse(args);

  // ---------------------------------------------------------------------------

  final help = argResults.flag(DefaultFlags.HELP.name);
  if (help) {
    _print(
      printCyan,
      parser.getInfo(argParser),
    );
    exit(ExitCodes.SUCCESS.code);
  }

  // ---------------------------------------------------------------------------

  late final String inputPath;
  late final String template;
  try {
    inputPath = argResults.option(DefaultOptions.INPUT_PATH.name)!;
    template = argResults.option(DefaultOptions.TEMPLATE_PATH_OR_URL.name)!;
  } catch (_) {
    _print(
      printRed,
      'Missing required args! Use --help flag for more information.',
    );
    exit(ExitCodes.FAILURE.code);
  }

  // ---------------------------------------------------------------------------

  final spinner = Spinner();
  spinner.start();

  // ---------------------------------------------------------------------------

  _print(
    printWhite,
    'Looking for files..',
  );
  final filePathStream0 = PathExplorer(inputPath).exploreFiles();
  final filePathStream1 = filePathStream0.where((e) {
    final path = p.relative(e.path, from: inputPath);
    return _isAllowedFileName(path);
  });
  List<FilePathExplorerFinding> findings;
  try {
    findings = await filePathStream1.toList();
  } catch (e) {
    _print(
      printRed,
      'Failed to read file tree!',
      spinner,
    );
    exit(ExitCodes.FAILURE.code);
  }
  if (findings.isEmpty) {
    spinner.stop();
    _print(
      printYellow,
      'No files found in $inputPath!',
    );
    exit(ExitCodes.SUCCESS.code);
  }

  // ---------------------------------------------------------------------------

  String templateData;
  _print(
    printWhite,
    'Reading template at: $template...',
  );
  // ignore: invalid_use_of_visible_for_testing_member
  final result =
      (await MdTemplateUtility.i.readTemplateFromPathOrUrl(template).toSync())
          .value;

  if (result.isErr()) {
    spinner.stop();
    _print(
      printRed,
      ' Failed to read template!',
    );
    exit(ExitCodes.FAILURE.code);
  }
  templateData = result.unwrap();

  // ---------------------------------------------------------------------------

  _print(
    printWhite,
    'Generating...',
    spinner,
  );

  for (final finding in findings) {
    final filePath = finding.path;
    try {
      await _generateForFile(filePath, templateData);
    } catch (_) {
      _print(
        printRed,
        'Failed to write at: $filePath',
        spinner,
      );
    }
  }

  // ---------------------------------------------------------------------------

  spinner.stop();
  _print(
    printGreen,
    'Done!',
  );
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

Future<void> _generateForFile(
  String filePath,
  String template,
) async {
  final commentStarter =
      langFileCommentStarters[p.extension(filePath).toLowerCase()] ?? '//';
  var templateLines = template.split('\n');
  final sourceLines =
      (await FileSystemUtility.i.readLocalFileAsLinesOrNull(filePath)) ?? [];
  if (sourceLines.isNotEmpty) {
    // Replace leading '//' in all template lines with the comment starter
    templateLines = templateLines.map((line) {
      if (line.trim().startsWith('//')) {
        return commentStarter + line.substring(2); // Replace leading // only
      }
      return line; // Return the line unchanged if it doesn't start with //
    }).toList();

    for (var n = 0; n < sourceLines.length; n++) {
      final line = sourceLines[n].trim();
      if (line.isEmpty || !line.startsWith(commentStarter)) {
        final withoutHeader = sourceLines.sublist(n).join('\n');
        final withHeader =
            '${templateLines.join('\n')}\n\n${withoutHeader.trimLeft()}\n';
        await FileSystemUtility.i.writeLocalFile(filePath, withHeader);
        break;
      }
    }
  }
}

void _print(
  void Function(String) print,
  String message, [
  Spinner? spinner,
]) {
  spinner?.stop();
  print('[gen-header-comments] $message');
  spinner?.start();
}

bool _isAllowedFileName(String e) {
  final lc = e.toLowerCase();
  return !lc.startsWith('_') &&
      !lc.contains('${p.separator}_') &&
      !lc.endsWith('.g.dart') &&
      langFileCommentStarters.keys
          .any((ext) => lc.endsWith(ext.trim().toLowerCase()));
}

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
