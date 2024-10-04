//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// 🇽🇾🇿 & Dev
//
// Licencing details are in the LICENSE file in the root directory.
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

import 'dart:io' show Directory;

import 'package:args/args.dart';
import 'package:df_gen_core/df_gen_core.dart';

import 'generate.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

Future<void> generateCommentHeadersApp(List<String> args) async {
  await runCommandLineApp(
    title: 'Generate Comment Headers by DevCetra.com',
    description: '...',
    args: args,
    parser: ArgParser()
      ..addFlag(
        'help',
        abbr: 'h',
        negatable: false,
        help: 'Help information.',
      )
      ..addOption(
        'roots',
        abbr: 'r',
        help: 'Root directory paths separated by `&`.',
        defaultsTo: Directory.current.path,
      )
      ..addOption(
        'subs',
        abbr: 's',
        help: 'Sub-directory paths separated by `&`.',
        defaultsTo: '.',
      )
      ..addOption(
        'patterns',
        abbr: 'p',
        help: 'Path patterns separated by `&`.',
      )
      ..addOption(
        'template',
        abbr: 't',
        help: 'Template file path or URL.',
        defaultsTo:
            'https://raw.githubusercontent.com/robmllze/df_generate_comment_headers/main/templates/v0.dart.md',
      ),
    onResults: (parser, results) {
      return _ArgsChecker(
        templateFilePath: results['template'] as String?,
        rootPaths: splitArg(results['roots'])?.toSet(),
        subPaths: splitArg(results['subs'])?.toSet(),
        pathPatterns: splitArg(results['patterns'])?.toSet(),
      );
    },
    action: (parser, results, args) async {
      await generateCommentHeaders(
        rootDirPaths: args.rootPaths ?? const {},
        subDirPaths: args.subPaths ?? const {},
        pathPatterns: args.pathPatterns ?? {},
        templateFilePath: args.templateFilePath!,
      );
    },
  );
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class _ArgsChecker extends ValidArgsChecker {
  //
  //
  //

  final Set<String>? rootPaths;
  final Set<String>? subPaths;
  final Set<String>? pathPatterns;
  final String? templateFilePath;

  //
  //
  //

  const _ArgsChecker({
    required this.rootPaths,
    required this.subPaths,
    required this.pathPatterns,
    required this.templateFilePath,
  });

  //
  //
  //

  @override
  List<dynamic> get args {
    final paths = [
      if (rootPaths != null) rootPaths,
      if (subPaths != null) subPaths,
    ];
    return [
      paths,
      ...paths,
      if (pathPatterns != null) pathPatterns,
      if (templateFilePath != null) templateFilePath,
    ];
  }
}
