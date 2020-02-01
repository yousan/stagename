#!/usr/bin/env bash
# 現在のブランチ名からブランチハッシュを取得する
# ブランチハッシュ => ブランチ名からスラッシュの置換、文字列を短く、ハッシュを付加してサニタイズしたもの。
# AWS用に文字数の制限を入れている。
# e.g. master => master
# e.g. develop => develop
# e.g. feature/yousan/test => feature-yousan-test-faaa59
# e.g. feature/yousan/something-toooooooooooooooooooooooooooooooooooo-long-branch-name => feature-yousan-something-tooooooooooooooooooooooooooooooo-379fca
set -xe

# 現在のブランチ名を取得する
# DyanmoDBのテーブル名の最大長は255文字 @see https://docs.aws.amazon.com/ja_jp/amazondynamodb/latest/developerguide/HowItWorks.NamingRulesDataTypes.html
# CloudFormationのスタック名の最大長は 64文字（たぶん）
# そのためここでは 21文字+3文字ハッシュとする
BRANCH=`git rev-parse --abbrev-ref HEAD`

if [[ "$BRANCH" == "master" ]]; then # masterとdevelopの場合にはハッシュを付けない
  echo "master"
  exit;
fi

if [[ "$BRANCH" == "develop" ]]; then
  echo "develop"
  exit;
fi

# s3やcloudfrontの命名規則に従うようにサニタイズする
# スラッシュをハイフンにし、57文字以下に制限。
# 大文字は小文字にし、英数字以外の文字は無視する
# ブランチ名は「feature/<yyyymm形式の時期>/<コミッタ名>/<タスク名>」を、
# 「<mm><コミッタ名[0:4]>-<タスク名>」の形式にして冒頭20文字をとったものにする
# e.g. 06yous-try-to-fix-de-51c  feature/201905/yousan/fix-deploy-script

TIME=`echo ${BRANCH} | cut -d "/" -f2 | cut -c 5-6` # 年月を取得
COMMITTER=`echo ${BRANCH} | cut -d "/" -f3 | cut -c 1-4` # コミッタ名
TASK=`echo ${BRANCH} | cut -d "/" -f4` # 最後のタスク名
# 小文字に変換 -> 記号系を省く -> 20文字以内に抑える
SANITIZED=`echo ${TIME}${COMMITTER}-${TASK} | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/" | sed -e 's/[^a-z0-9-]//g' | cut -c 1-20`

if type "md5" > /dev/null 2>&1; then
  BRANCH_HASH=$(echo ${BRANCH} | md5 | cut -c 1-3) # ブランチ名からのハッシュ値を取得。スタック名に使用する。
else
  # CircleCIのubuntuはmd5sumコマンドを使う（本当はelseifしたい)
  BRANCH_HASH=$(echo ${BRANCH} | md5sum | cut -c 1-3) # ブランチ名からのハッシュ値を取得。スタック名に使用する。
fi

# サニタイズ＋ハッシュ値を計算
echo ${SANITIZED}-${BRANCH_HASH}
