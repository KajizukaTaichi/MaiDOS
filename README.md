![MaidOS Running Screenshot](https://github.com/user-attachments/assets/7c5fffd2-d883-4c6b-bc1b-1f2c7092b148)

## 起動方法

このリポジトリをローカルにクローンして、`make`でビルドして実行します。
```bash
git clone https://github.com/KajizukaTaichi/MaiDOS.git
cd ./MaiDOS
make
```
ビルドには以下のツールが必要になります。

- **make**:<br>
  ビルド作業を自動化するツールです。
  先ほどのコードの3行目で`make`するのに使います
- **nasm**: <br>
  アセンブラです。
  ソースコード[`kernel.asm`](./kernel.asm) から機械語のバイナリを出力するのに使います。
- **qemu**:<br>
  実機がなくても仮想的に実行できるエミュレータです。
  `nasm`が吐いたバイナリを実行するのに使います。

これらは事前にインストールしてある必要があります。
ない場合は実行する前にインストールしてください。
