const vscode = require("vscode");

module.exports = {
  activate(context) {
    context.subscriptions.push(
      vscode.commands.registerCommand("copyRelativePathWithLine", () => {
        const editor = vscode.window.activeTextEditor;
        if (!editor) return;

        const path = vscode.workspace.asRelativePath(editor.document.uri);
        const sel = editor.selection;

        if (sel.isEmpty) {
          vscode.env.clipboard.writeText(path);
          return;
        }

        const start = sel.start.line + 1;
        const end = sel.end.line + 1;
        const lineRef = start === end ? `:${start}` : `:${start}-${end}`;

        vscode.env.clipboard.writeText(path + lineRef);
      }),
    );
  },
};
