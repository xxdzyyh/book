总所周知，在cell重用之前必须先注册，否则就会出问题，tableView会返回nil，collectionView会直接闪退。

但是注册和重用的代码几乎都是一个样，有没有办法不每次都写这些代码？添加下面的extension，可以解决大多数情况下cell注册问题

> UITableViewCell

```
extension UITableViewCell {
    class func register(for tableView:UITableView, identifier:String? = nil) {
        var reuseIdentifier = identifier
        if reuseIdentifier == nil {
          reuseIdentifier = self.className
        }
        let classBundle = Bundle.init(for: self)
        let path = classBundle.path(forResource: className, ofType: "nib")
        if (path != nil) {
            let nib = UINib.init(nibName: className, bundle: classBundle)
            
            tableView.register(nib, forCellReuseIdentifier: reuseIdentifier!)
        } else {
            tableView.register(self, forCellReuseIdentifier: reuseIdentifier!)
        }
    }

    class func cell(for tableView: UITableView, identifier:String? = nil) -> (UITableViewCell) {
        var reuseIdentifier = identifier
        if reuseIdentifier == nil {
          reuseIdentifier = self.className
        }
        var cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier!)
        if cell == nil {
            register(for: tableView, identifier: reuseIdentifier!)
            cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier!)
        }
        return cell!
    }
}
```

调用的地方无需注册，只需要将 `tableView.dequeueReusableCell(withIdentifier: reuseIdentifier!)`换成`ClassName.cell(for: tableView)`就可以了。

```
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = XTableViewCell.cell(for: tableView) as! XTableViewCell
    return cell
}
```

下面的代码中，cell == nil 就会去注册，然后，下次重用不会为空，所以只会注册一次。

```
if cell == nil {
    register(for: tableView, identifier: reuseIdentifier!)
    cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier!)
}
```



> UICollectionViewCell

UICollectionViewCell要稍微麻烦一点，如果没有注册会直接crash，但是可以使用try-catch避免闪退，其他的和UITableViewCel一致l。

```
import UIKit
import SwiftTryCatch

extension UICollectionViewCell {
    
    class func register(for collectionView:UICollectionView, identifier:String? = nil) {
        register(for: collectionView, identifier: identifier, nibName: self.className)
    }
    
    class func register(for collectionView:UICollectionView, identifier:String? = nil, nibName:String) {
        var reuseIdentifier = identifier
        if reuseIdentifier == nil {
           reuseIdentifier = self.className
        }
        
        let classBundle = Bundle.init(for: self)
        let path = classBundle .path(forResource: nibName, ofType: "nib")
        if path != nil {
            let nib = UINib(nibName: nibName, bundle: nil)
            collectionView.register(nib, forCellWithReuseIdentifier: reuseIdentifier!)
        } else {
            collectionView.register(self, forCellWithReuseIdentifier: reuseIdentifier!)
        }
    }
    
    class func cell(for collectionView:UICollectionView, identifier:String? = nil, indexPath:IndexPath, nibName:String? = nil) -> UICollectionViewCell {
        var reuseIdentifier = identifier
        if reuseIdentifier == nil {
           reuseIdentifier = self.className
        }
        /**
         collectionView在没有register的情况下，调用 dequeueReusableCell会crash，
         tableView不会，所以tableView可以先dequeueReusableCell，为nil 再去register
            
         解决crash的方法也很简单，使用try catch 就可以，如果catch到异常，注册一下，下次就不会有异常了

            do {
                let cell = try collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier!, for: indexPath) as! XBaseCollectionViewCell

                return cell
            } catch {
                self.register(for: collectionView)
                 let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier!, for: indexPath) as! XBaseCollectionViewCell

                return cell
            }
         
        使用swift的do catch 无法捕获这个异常，但是使用oc的 @try 可以
         */
        var cell : UICollectionViewCell?
        SwiftTryCatch.try({
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier!, for: indexPath)
        }, catch: { (exception) in
            register(for: collectionView,identifier:identifier,nibName: nibName ?? self.className)
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier!, for: indexPath)
        }, finally: nil)
        
        return cell!
    }
}

```



