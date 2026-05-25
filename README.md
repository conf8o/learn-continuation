# 継続の勉強

effect systemの理解を目標として、まずはその文脈となる継続周りを理解する。

- Racketの call/cc から、古典的な継続を理解する
- OCamlの effect handler から、安全にハンドリングできる継続を理解する

---

- OCaml 5.4
  - opamのインストールは、公式のインストールスクリプトがおすすめ。[インストールページ](https://ocaml.org/install#linux_mac_bsd)
  - [mise](https://mise.jdx.dev/getting-started.html) プラグインも一応あるが、リポジトリは自身を推奨していない。[mise-ocaml](https://github.com/mise-plugins/mise-ocaml)
  - [effect handler](https://ocaml.org/manual/5.4/effects.html)
- Racket 9.1
  - racketのインストールは、miseからでいいかも。[mise-racket](https://github.com/mise-plugins/mise-racket)
    ```
    mise plugin install racket https://github.com/mise-plugins/mise-racket.git
    mise install
    ```
  - [公式のインストールスクリプトダウンロードページ](https://racket-lang.org/download/)
  - [call/cc](https://docs.racket-lang.org/guide/conts.html)

## 開発環境の設定

エディタはZed想定。それぞれ拡張機能を入れる。

`init.sh`を実行してそれぞれの言語サーバーやフォーマッターを入れる
