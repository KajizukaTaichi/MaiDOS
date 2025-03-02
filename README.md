![MaiDOS Running Screenshot](https://github.com/user-attachments/assets/7c5fffd2-d883-4c6b-bc1b-1f2c7092b148)

## セットアップ

このリポジトリを**git**でお使いのPCにクローンして、**make**でビルドして起動します。
```bash
git clone https://github.com/KajizukaTaichi/MaiDOS.git
cd ./MaiDOS
make
```
ビルドには以下のツールが必要になります。
ない場合は実行する前にインストールしてください。

- **make:**
  OSのビルド作業を自動化するのに使います。
- **nasm:** 
  ソースコード(`kernel.asm`)から機械語のバイナリを出力するのに使います。
- **qemu:**
  実機の代わりに**nasm**が吐いたOSバイナリを動かすのに使います。

