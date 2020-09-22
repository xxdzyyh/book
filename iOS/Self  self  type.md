## Self  self  type

```swift
'Self' is only available in a protocol or as the result of a method in a class
```

```
extension UITableViewCell {
    func cell(for tableView:UITableView) -> Self {
    		// dequeueReusableCell 获取到的是什么类型就放回什么类型
        return tableView.dequeueReusableCell(withIdentifier: "identifer") as! Self
    }
}
```

