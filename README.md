# OrgEval

OrgEval is a plugin for evaluating emacs' org mode source blocks in vim.

![GIF Demo](https://raw.github.com/aloussase/OrgEval.vim/master/doc/demo.gif)

## Quickstart

If you are familiar with emacs' source block evaluation, then you can just get
started using the default mappings. If you do not want to use the default
mappings, set `org_eval_map_keys = 0` and create your own.

To see the available commands `:help OrgEval`.

## Supported Languages

As of now, OrgEval supports evaluation of

| Language | Command |
|----------|---------|
| C        | `tcc -run`    |
| Clojure  | `clojure`     |
| Haskell  | `runhaskell`  |
| awk      | `awk -f`      |
| bash     | `bash`        |
| java     | `java --source 11` |
| python   | `python3`     |
| sh       | `sh`          |

Look into the documentation for ways of adding more languages.

## Contributing

Feel free to submit a pull request to make OrgEval better!
