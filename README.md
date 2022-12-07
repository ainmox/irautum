# irautum

## Pool

### Parameters

| Parameter            | Type           | Summary                                                               |
|----------------------|----------------|-----------------------------------------------------------------------|
| `admin`              | `address`      | The administrator of the pool                                         |
| `reserveFactor`      | `UFixed16x4`   | The proportion of the accrued interest that is retained for reserves  |
| `minimumBorrowRate`  | `UFixed80x18`  | The borrow rate when the utilization is at its minimum value          |
| `maximumBorrowRate`  | `UFixed80x18`  | The borrow rate when the utilization is at its maximum value          |
| `optimalBorrowRate`  | `UFixed80x18`  | The borrow rate when the utilization is at its optimal value          |
| `optimalUtilization` | `UFixed16x4`   | The utilization that the pool that the pool is attempting to maintain |