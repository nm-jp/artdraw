#!/bin/sh
set -eu

######################################################################
# 設定
######################################################################

print_usage_and_exit () {
  cat <<-USAGE 1>&2
	Usage   : ${0##*/} -p<開始座標> [座標ファイル]
	Options : -c<対象文字>

	開始座標から到達できる連続領域の座標を深さ優先順にソートする。

	-pオプションで探索の開始座標を指定する。
	-cオプションで領域を構成する座標を指定できる。デフォルトは■。

	座標ファイルのデータは以下の形式であることを想定する。
	 <x座標> <y座標>
	USAGE
  exit 1
}

######################################################################
# パラメータ
######################################################################

# 変数を初期化
opr=''
opt_p=''
opt_c='40'

# 引数をパース
i=1
for arg in ${1+"$@"}
do
  case "$arg" in
    -h|--help|--version) print_usage_and_exit ;;
    -p*)                 opt_p=${arg#-p}      ;;
    -c*)                 opt_c=${arg#-c}      ;;
    *)
      if [ $i -eq $# ] && [ -z "$opr" ]; then
        opr=$arg
      else
        echo "${0##*/}: invalid args" 1>&2
        exit 11
      fi
      ;;
  esac

  i=$((i + 1))
done

# 標準入力または読み取り可能な通常ファイルであるか判定
if   [ "_$opr" = '_' ] || [ "_$opr" = '_-' ]; then     
  opr=''
elif [ ! -f "$opr"   ] || [ ! -r "$opr"    ]; then
  echo "${0##*/}: \"$opr\" cannot be opened" 1>&2
  exit 21
else
  :
fi

# 有効な数値であるか判定
if ! printf '%s\n' "$opt_p" | grep -Eq '^[0-9]+$'; then
  echo "${0##*/}: \"$opt_p\" invalid coordinate" 1>&2
  exit 31
fi

# 有効な数値であるか判定
if ! printf '%s\n' "$opt_c" | grep -Eq '^.$'; then
  echo "${0##*/}: \"$opt_c\" invalid character" 1>&2
  exit 41
fi

# パラメータを決定
coord=$opr
sp=$opt_p
tchar=$opt_c

######################################################################
# 本体処理
######################################################################




gawk '
BEGIN {
  # パラメータを設定
  height = '"${height}"';
  width  = '"${width}"';

  # 空のキャンバスを作成
  for (i = 1; i <= height; i++) {
    for (j = 1; j <= width; j++) {
      buf[i,j] = "□";
    }
  }

  # エラーステータスを初期化
  estate = 0;
}

{
  # データの整合性をチェック
  if (($1 !~ /^-?[0-9]+$/) || ($2 !~ /^-?[0-9]+$/)) {
    print "'"${0##*/}"': invalid number at line " NR > "/dev/stderr";
    estate = 51;
    exit estate;
  }

  # 座標値を確定
  x = $1; y = $2;

  # 文字を出力
  if   (NF >= 3) { buf[y,x] = $3;   }
  else           { buf[y,x] = "■"; }
}

END {
  if (estate == 0) {
    # データに不整合がなければキャンバスを出力
    for (i = 1; i <= height; i++) {
      for (j = 1; j <= width; j++) {
        printf "%s", buf[i,j];
      }

      print "";
    }
  }
}
' ${coord-:"$coord"}