![MaiDOS Running Screenshot](https://github.com/user-attachments/assets/7c5fffd2-d883-4c6b-bc1b-1f2c7092b148)

## セットアップ

このリポジトリをローカルにクローンして、`make`でビルドして実行します。
```bash
git clone https://github.com/KajizukaTaichi/MaiDOS.git
cd ./MaiDOS
make
```
ビルドには以下のツールが必要になります。
ない場合は実行する前にインストールしてください。

- **make:**
  ビルド作業を自動化するツールです。
  先ほどのコードの3行目で`make`するのに使います。
- **nasm:** 
  アセンブラです。
  ソースコード(`kernel.asm`)から機械語のバイナリを出力するのに使います。
- **qemu:**
  実機が無くても仮想的に実行できるエミュレータです。
  `nasm`が吐いたバイナリを動かすのに使います。

