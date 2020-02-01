# stagename

特定のルールに従ったGitのブランチ名からステージ名を生成します。

命名規則は下記の通りです。

```
年月/ユーザー名/機能名
```

例) 202001/yousan/fix-admin-panel

AWSのクラウドフォーメーションのスタック用に切り詰めてステージ名を決定しています。

ステージ名の末尾にハッシュをつけることで途中まで同じ名前のブランチも別のステージ名となるようにしています。

```
$ curl -L -s https://raw.githubusercontent.com/yousan/stagename/master/aws.sh | bash

06hiro-paymentcheckl-a44
```
