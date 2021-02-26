### gitbook

如果出现端口占用，可以指定端口。

```
gitbook serve --lrport 35288 --port 4001 book_dir
```

### gitbook build生成的__book,直接打开index.html无法跳转

1. 在_book文件夹中找到gitbook->theme.js文件
2. 在代码中搜索

```css
 if(m)for(n.handler&&
```

将if(m)改成if(false)，再重新打开index.html即可

