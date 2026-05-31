## 題材: コインランドリー予約の状態遷移

### 洗濯機の状態

```text
MachineStatus =
  Preparing
  Available
  Reserved
  Running
```

### 状態遷移表

- `Preparing`:
  - -> `Available`: 準備が完了し、運転が可能になった
  - -> `Reserved`: 準備が完了し、事前予約をセットした
  - -> `Running`: ✕
- `Available`:
  - -> `Preparing`: 洗濯機の準備中(想定外)
  - -> `Reserved`: 予約された
  - -> `Running`: 予約なしで現地利用された
- `Reserved`:
  - -> `Preparing`: 予約がキャンセルされ、洗濯機を準備中(想定外)
  - -> `Running`: 予約者が運転を開始した
  - -> `Available`: 予約がキャンセルされ、運転が可能になった
- `Running`:
  - -> `Preparing`: 運転終了
  - -> `Available`: ✕
  - -> `Reserved`: ✕
