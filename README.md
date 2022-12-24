# irautum

## Pool

### Parameters

| Parameter            | Type           | Summary                                                          |
|----------------------|----------------|------------------------------------------------------------------|
| `depositLimit`       | `uint256`      | The maximum amount of assets that can be deposited into the pool | 
| `optimalUtilization` | `UFixed256x18` | The utilization that the pool is attempting to maintain          |
| `minimumBorrowRate`  | `UFixed256x18` | The borrow rate when the utilization is at its minimum value     |
| `maximumBorrowRate`  | `UFixed256x18` | The borrow rate when the utilization is at its maximum value     |
| `optimalBorrowRate`  | `UFixed256x18` | The borrow rate when the utilization is at its optimal value     |
| `minimumSupplyRate`  | `UFixed256x18` | The supply rate when the utilization is at its minimum value     |
| `maximumSupplyRate`  | `UFixed256x18` | The supply rate when the utilization is at its maximum value     |
| `optimalSupplyRate`  | `UFixed256x18` | The supply rate when the utilization is at its optimal value     |