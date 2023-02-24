# AutoClip
ゲームプレイ動画から自動でキルやデスのシーンを切り抜くアプリです。


## インストール
OpenCVやRealmはgitにあげていないので自分で導入する必要があります。

### OpenCV
リポジトリをクローンしてビルドをします
```bash
git clone https://github.com/opencv/opencv.git

./build_framework.py <outputdir>
```

build_framework.pyを実行するとopencv2.frameworkが作成されるので、それを/AutoClip/common/に入れます。

このサイトが参考になるかもしれません
https://qiita.com/treastrain/items/0090d1103033b20de054

### Realm
プロジェクトフォルダ内でpod installすればOKなはずです。

## テスト動画
https://drive.google.com/file/d/1Vsh7J94LFmy0y3IDyq4wFXQ9aZR7mI0K/view?usp=sharing
