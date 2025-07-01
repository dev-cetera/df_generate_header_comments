This tool automatically adds standardized comment headers to your source files, enhancing protection, consistency, and authenticity across your codebase.

## How to Use

### With Visual Studio Code

1. Install the extension here: https://marketplace.visualstudio.com/items?itemName=Dev-Cetera.dev-cetera-df-support-commands
2. Create a template file in your project's directory and call it `header_template.md`:

   ````md
   ```dart
   // The use of this source code is governed by the LICENSE file located in this
   // project's root directory.
   ```
   ````

3. Back up your source code!
4. Right-click on any folder in your project and select `🔹 Generate Header Comments`.
5. Alternatively, right-click a folder and select `"Open in Integrated Terminal"` then run `--headers -t path/to/header_template.md` in the terminal.
6. This will modify source files in the folder and add the header comments.

### Without Visual Studio Code

1. Install this tool by running: `dart pub global activate df_generate_header_comments`.
2. Back up your source code!
3. Create a template file and call it something like `header_template.md`:

   ````md
   ```dart
   // The use of this source code is governed by the LICENSE file located in this
   // project's root directory.
   ```
   ````

4. Open a terminal at a desired folder then run `--headers -t path/to/header_template.md` in the terminal. This will modify source files in the folder and add the header comments.
