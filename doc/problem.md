## 題材: ホテル内コインランドリー予約システム

### 要件

- ホテル宿泊者は、部屋のテレビから洗濯機の状態を確認できる。
- 洗濯機は予約利用と現地利用ができる。
- 洗濯時間は40分固定。
- 予約枠は1時間。
- 予約枠開始時間から10分が経過すると自動キャンセルされる。
- 予約枠終了時間を超えても洗濯物を取り出さず、下記のいずれかの場合、強制的にスタッフが洗濯物を取り出す。
  - 次の予約開始時間が控えている場合
  - 他のユーザーから申告があった場合

## ユーザーストーリー

- 宿泊者として、部屋のテレビから空いている洗濯機を確認したい
- 宿泊者として、使いたい時間に洗濯機を予約したい。
- 宿泊者として、予約時間になったら洗濯機を開始したい。
- 宿泊者として、予約なしでも空いている洗濯機をその場で使いたい。
- 宿泊者として、不要になった予約をキャンセルしたい。
- システムとして、洗濯機の中の状態を検査したい

## 要件

### 洗濯機の状態

```text
MachineStatus =
  Preparing
  Available
  Reserved
  Running
```

### 状態遷移表

状態遷移にはそれぞれイベント名をつける。主語は洗濯機とする。

- `Preparing`:
  - -> `Available`: 準備が完了し、運転が可能になった(`GetReady`)
  - -> `Reserved`: 準備が完了し、事前予約をセットした(`AcceptAdvanceReservation`)
  - -> `Running`: ✕
- `Available`:
  - -> `Preparing`: 洗濯機の準備中(想定外)(`PrepareOnUnexpected`)
  - -> `Reserved`: 予約された(`AcceptReservation`)
  - -> `Running`: 予約なしで現地利用された(`RunOnSite`)
- `Reserved`:
  - -> `Preparing`: 予約がキャンセルされ、洗濯機を準備中(想定外)(`CancelReservationOnUnexpected`)
  - -> `Running`: 予約者が運転を開始した(`GetStarted`)
  - -> `Available`: 予約がキャンセルされ、運転が可能になった(`GetCanceledReservation`)
- `Running`:
  - -> `Preparing`: 運転終了(`Finish`)
  - -> `Available`: ✕
  - -> `Reserved`: ✕
