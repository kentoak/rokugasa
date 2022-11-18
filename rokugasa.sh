
#!/bin/sh

unixtime2datetime() {
    set -- $(( $1%86400 )) $(( $1/86400+719468 )) 146097 36524 1461
    set -- "$1" "$2" $(( $2-(($2+2+3*$2/$3)/$5)+($2-$2/$3)/$4-(($2+1)/$3) ))
    set -- "$1" "$2" $(( $3/365 ))
    set -- "$@" $(( $2-( (365*$3)+($3/4)-($3/100)+($3/400) ) ))
    set -- "$@" $(( ($4-($4+20)/50)/30 ))
    set -- "$@" $(( 12*$3+$5+2 ))
    set -- "$1" $(( $6/12 )) $(( $6%12+1 )) $(( $4-(30*$5+3*($5+4)/5-2)+1 ))
    set -- "$2" "$3" "$4" $(( $1/3600 )) $(( $1%3600 ))
    set -- "$1" "$2" "$3" "$4" $(( $5/60 )) $(( $5%60 ))
    printf "%04d-%02d-%02d %02d:%02d:%02d\n" "$@"
}

if [ $# = 1 ]; then
    # チャンネル名, チャンネルタイプ, 番組名, 番組概要の読み込み
    if [ -z "$CHANNELNAME" ]; then
        CHANNELNAME="放送局名なし"
    else
        :
    fi
    if [ -z "$NAME" ]; then
        title="タイトル未設定"
    else
        title=$NAME
    fi
    if [ -z "$DESCRIPTION" ]; then
        description="番組概要が指定されていません。"
    else
        description=$DESCRIPTION
    fi
    if [ -z "$STARTAT" ]; then
        startat="未設定"
    else  
    	 start_epg_time=$(($STARTAT/1000))
        start_ust_time=$( unixtime2datetime $start_epg_time )
        start_jst_time=$( date -d "$start_ust_time 9hours" +'%m/%d(%a)   %H:%M')
        startat=$start_jst_time        
    fi
    if [ -z "$ENDAT" ]; then
        endat="未設定"
    else
        end_epg_time=$(($ENDAT/1000))
        end_ust_time=$( unixtime2datetime $end_epg_time )
        end_jst_time=$( date -d "$end_ust_time 9hours" +'%H:%M')
        endat=$end_jst_time
    fi
    if [ -z "$DURATION" ]; then
    	duration="未設定"
    else
        duration=$(($DURATION/60000))
    fi
    if [ -z "$EXTENDED" ]; then
        extended="未設定"
    else
        extended=$EXTENDED
    fi
       
    # 引数をコピー (コマンドとして認識されるのを防ぐため)
    ret=$1

    # 予約関係: 追加, 削除, 更新, 録画準備
    if [ $ret = "reserve" ]; then
        content="\n ✅ 予約追加 \n ${title} \n ${CHANNELNAME} \n ${startat}~${endat}     ${duration}"分"\n ${description} \n ${extended}"
    elif [ $ret = "delete" ]; then
        content="\n 💨 予約削除 \n ${title} \n ${CHANNELNAME}"
    elif [ $ret = "update" ]; then
         content="\n 🔁 予約更新 \n ${title} \n ${CHANNELNAME} \n ${startat}~${endat}     ${duration}"分""
    elif [ $ret = "prestart" ]; then
        content="\n 🔷 録画準備開始 \n ${title}　\n ${CHANNELNAME}"
    elif [ $ret = "prepfailed" ]; then
        content="\n 💥 録画準備失敗 \n ${title}　\n ${CHANNELNAME}"
    elif [ $ret = "start" ]; then
        content="\n ⏺ 録画開始 \n ${title}　\n ${CHANNELNAME}"
    elif [ $ret = "encod_end" ]; then
        content="\n ⏹ エンコード終了 \n ${title} \n ${CHANNELNAME}"
    elif [ $ret = "end" ]; then
          # エラー, ドロップ, スクランブルカウントを読み込み
        if [ -z "$ERROR_CNT" ]; then
            ERROR_CNT="N/A"
        else
            : # 何もしない
        fi
        if [ -z "$DROP_CNT" ]; then
            DROP_CNT="N/A"
        else
            : # 何もしない
        fi
        if [ -z "$SCRAMBLING_CNT" ]; then
            SCRAMBLING_CNT="N/A"
        else
            : # 何もしない
        fi
        content="\n ⏹ 録画終了 \n ${title} \n ${CHANNELNAME} \n ${startat}~${endat}     ${duration}"分"  \n エラー: ${ERROR_CNT}, ドロップ: ${DROP_CNT}, スクランブル: ${SCRAMBLING_CNT}"
    elif [ $ret = "recfailed" ]; then 
        content="\n ❌ 録画失敗 \n ${title} \n ${CHANNELNAME}"
    else
        echo "引数が不正です。"
        exit 1
    fi
    /usr/bin/python3 /home/pi/EPGStation/config/postShTweet.py ${content}
else
    echo "引数を指定してください。"
fi
