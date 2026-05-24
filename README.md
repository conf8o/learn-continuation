# 継続の勉強

effect systemの理解を目標として、まずはその文脈となる継続周りを理解する。

- Racketの call/cc から、古典的な継続を理解する
- OCamlの effect handler から、安全にハンドリングできる継続を理解する

---

- OCaml 5.4
  - opamのインストールは、公式のインストールスクリプトがおすすめ。[解説ページ](https://ocaml.org/install#linux_mac_bsd)
  - [effect handler](https://ocaml.org/manual/5.4/effects.html)
- Racket 9.1
  - racketのインストールは、[mise](https://mise.jdx.dev/getting-started.html) からでいいかも
  - 公式はダウンロードさせてsh実行する形。([ダウンロードページ](https://racket-lang.org/download/))
  - [call/cc](https://docs.racket-lang.org/guide/conts.html)
