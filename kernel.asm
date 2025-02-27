; === MaiDOS ===

welcome:
    call APP_clear          ; BIOSの画面をクリア

    mov si, VAL_msg_welcome  ; 起動メッセージ
    call IO_printStr
    call IO_printNewLine    ; 改行して見やすくする


; === シェル ===

SHELL_start:
    call IO_printNewLine    ; 改行
    mov si, VAL_shPrompt    ; シェルのプロンプト文字列を表示
    call IO_printStr

    mov bx, 0   ; 入力バッファのインデックスを初期化
    xor dh, dh  ; Space入力フラグを初期化

SHELL_mainLoop:
    call IO_getKey      ; ユーザー入力取得

    cmp al, 0x0D        ; Enterキーかチェック (0x0D = CR)
    je SHELL_execute    ; 押されたらコマンド実行

    cmp al, ' '                 ; Spaceキーかチェック (0x0D = CR)
    je SHELL_mainLoop__space    ; 押されたら引数解析

    cmp al, 0x08                ; Backspaceキーかチェック (0x08 = BS)
    je IO_backspace

    call IO_printChar           ; 入力文字を画面に表示
    mov [BUF_input + bx], al    ; 入力をバッファに追加
    inc bx                      ; バッファを指すbxを進める

    jmp SHELL_mainLoop          ; ループ継続

SHELL_mainLoop__space:
    call IO_printChar               ; 入力文字を画面に表示

    cmp dh, 0                       ; Spaceがすでに入力されたかどうか
    jne SHELL_mainLoop__spaceTwice

    mov byte [BUF_input + bx], 0    ; Null文字をバッファに追加
    inc bx                          ; バッファを指すbxを進める
    inc dh                          ; Space入力フラグを立てる
    jmp SHELL_mainLoop              ; ループ継続

SHELL_mainLoop__spaceTwice:         ; 2回目以降に押されたSpaceの処理
    mov byte [BUF_input + bx], ' '  ; Space文字をバッファに追加
    inc bx                          ; バッファを指すbxを進める
    jmp SHELL_mainLoop              ; ループ継続

SHELL_execute:
    ; === シェルコマンドを実行 ===

    cmp bx, 0       ; 入力が空か
    je SHELL_start  ; プロンプト開始へ戻る

    mov byte [BUF_input + bx], 0    ; 文字列終端を追加
    call IO_printStr                ; 改行

    mov si, BUF_input       ; アプリ起動
    call KERNEL_launchApp

    call IO_printNewLine    ; 2回改行

    jmp SHELL_start         ; プロンプト開始へ戻る


; === カーネル ===

KERNEL_launchApp:
    ; == アプリを起動 ==

    mov si, BUF_input       ; 表示
    mov di, VAL_cmdLet_echo
    call STR_compare        ; 入力とコマンド名"echo"が同じか比較
    cmp ax, 1               ; ならば実行する
    je APP_echo

    mov si, BUF_input       ; 画面クリア
    mov di, VAL_cmdLet_clear
    call STR_compare        ; 入力とコマンド名"clear"が同じか比較
    cmp ax, 1               ; ならば実行する
    je APP_clear

    mov si, BUF_input       ; ヘルプ
    mov di, VAL_cmdLet_help
    call STR_compare        ; 入力とコマンド名"help"が同じか比較
    cmp ax, 1               ; ならば実行する
    je APP_help

    mov si, BUF_input       ; 終了
    mov di, VAL_cmdLet_shutdown
    call STR_compare        ; 入力とコマンド名"shutdown"が同じか比較
    cmp ax, 1               ; ならば実行する
    je APP_shutdown

    mov si, VAL_msg_error   ; マッチしない場合
    call IO_printStr
    mov si, BUF_input       ; エラーメッセージを出力
    call IO_printStr

KERNEL_appSuccess:
    ; == プロセス終了(成功) ==
    mov edi, BUF_input
    mov ecx, 16         ; バッファ初期化
    xor eax, eax
    rep stosd
    ret


; === アプリ ===

APP_echo:
    ; == 引数を表示 ==
    mov si, BUF_input
    add si, 5
    call IO_printStr
    jmp KERNEL_appSuccess

APP_clear:
    ; == 画面をクリア ==
    mov ax, 0x07c0
    mov ds, ax
    mov ah, 0x0
    mov al, 0x3
    int 0x10            ; BIOS コール
    jmp KERNEL_appSuccess

APP_help:
    ; == ヘルプを表示 ==
    mov si, VAL_msg_help
    call IO_printStr
    jmp KERNEL_appSuccess

APP_shutdown:
    ;  == シャットダウン ==
    mov ax, 0x5307      ; APM機能：Set Power State（電源状態の設定）
    mov bx, 1           ; デバイス番号（通常は1を指定、全デバイスに対して）
    mov cx, 3           ; 電源状態 3：シャットダウン（完全に電源オフする状態）
    int 15h             ; BIOS割り込み15hを呼び出してAPM関数を実行


; === 文字列操作 ===

STR_compare:        ; 文字列比較
    mov cx, 20      ; 最大20文字比較
STR_compare__loop:
    mov al, [si]    ; SI: 入力文字列, DI: 比較対象
    mov ah, [di]
    cmp al, ah
    jne STR_compare__noMatch    ; 違えば終了

    test al, al
    jz STR_compare__match       ; 両方の文字列が Null文字に到達したら一致

    inc si
    inc di
    jmp STR_compare__loop       ; 比較ループ継続
STR_compare__match:
    mov ax, 1
    ret
STR_compare__noMatch:
    xor ax, ax
    ret


; === 入出力処理(IO) ===

IO_getKey:
    mov ah, 0x00    ; 入力
    int 0x16        ; BIOS コール
    ret

IO_printChar:
    mov ah, 0x0E    ; 出力
    int 0x10        ; BIOS コール
    ret

IO_printStr:
    lodsb                   ; 文字をロード
    or al, al               ; Null文字か
    jz IO_printStr__done    ; ならば終了
    call IO_printChar
    jmp IO_printStr         ; 次の文字へ
IO_printStr__done:
    ret

IO_printNewLine:          ; 改行を出力
    mov si, VAL_newLine
    call IO_printStr
    ret

IO_backspace:
    cmp bx, 0
    jz SHELL_mainLoop   ; 何も入力されていなければスキップ
    dec bx
    mov ah, 0x0E
    mov al, 0x08
    int 0x10            ; カーソルを戻す
    mov al, ' '
    int 0x10            ; 空白を上書き
    mov al, 0x08
    int 0x10            ; カーソルを再び戻す
    jmp SHELL_mainLoop


; === データ ===

VAL_shPrompt db '[sh]> ', 0
VAL_newLine db 0x0D, 0x0A, 0

; コマンド群
VAL_cmdLet_echo db 'echo', 0
VAL_cmdLet_clear db 'clear', 0
VAL_cmdLet_help db 'help', 0
VAL_cmdLet_shutdown db 'shutdown', 0

; メッセージ群
VAL_msg_welcome:
    db 'Welcome back to computer, master!', 0
VAL_msg_error:
    db 'Error! unknown command: ', 0
VAL_msg_help:
    db 'MaiDOS v0.2.5', 0x0D, 0x0A, \
    '(c) 2025 Kajizuka Taichi', 0x0D, 0x0A, \
    'Commands: echo, clear, help, shutdown', 0

; コマンド入力受け付け用バッファ領域
BUF_input times 16 db 0

; 残りのバイト列を埋める
times 510-($-$$) db 0
; ブートセクタの印
db 0x55
db 0xAA
