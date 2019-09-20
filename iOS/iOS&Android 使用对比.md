---
layout: post
title: iOS&Android对比
type: Android
---



[TOC]

### 添加权限

> Android

在 project/app/src/main/AndroidManifest.xml 中添加

```
# 和 application 标签同级
<uses-permission android:name="android.permission.INTERNET"/>

<application .../>
```

> iOS

* info.plist 
* Target -> Capabilities

### 添加依赖

android gradle 和 iOS cocoapods 有一些类似的地方。

在 project/app/src/build.gradle （类似于podfile）中添加依赖.

```
dependencies {
	 # 添加需要的依赖
    compile 'com.alibaba:fastjson:1.2.33'
}

```

重新build，gradle 会去同步,相当于 pod update。

>iOS

cocoapods


### 图片

> xml


```
<ImageView android:src="@"/>
```
> class

```
context.getResources().getDrawable(R.mipmap.icon_order);
```

> SDWebImage & Glide

```
Glide.with((Fragment) mListener).load(tag.coverImage).into(holder.mBackImageView);
```

> contentMode & scaleType

AspectFit = CenterCrop    
    
### 表格

> Android

RecyclerView / ListView    

早期都是使用ListView，后面有了RecyclerView，使用上大同小异。

1. 创建RecyclerView / ListView
2. 创建相应的Adapter，类似于创建一个Adapter类实现tableView的delegate/dataSource协议
3. 将Adapter和view进行关联，通过Adapter控制view的内容

更新整个表格

```
List list = new JSONObject().parseArray(res.data.toString(),FollowOrder.class);

dataSources.clear();
dataSources.addAll(list);

// 要注意的是adpter刷新前后dateSet必须是同一对象，否则notifyDataSetChanged无效，这个比较垃圾
mViewAdapter.notifyDataSetChanged();
```
> iOS

UICollectionView & UITableView 

UITableView始终是单列，UICollectionView可以多行多列。

### 数据持久化

>iOS

NSUserDefault 

>Android

SharedPreferences

```
// 获取一个SharedPreferences实例，名称是NSUserDefaults，如果没有就创建，非常SB的地方是必须由context去获取
SharedPreferences userDefaults = context.getSharedPreferences("NSUserDefaults",0);
SharedPreferences.Editor editor = userDefaults.edit();
// 增加
editor.putString("name",name);
// 删
editor.remove("name");
editor.commit();
```

### fragment

```
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;

public class MainActivity extends Activity implements LikeFragment.OnListFragmentInteractionListener {
	private FragmentManager manager;
   private FragmentTransaction transaction;
   private LikeFragment likeFragment;
	
	
    @Override
    protected void onCreate(Bundle savedInstanceState) {
       super.onCreate(savedInstanceState);
       setContentView(R.layout.activity_main);

       showFragments(likeFragment,"like");
    }
	
	void showFragments(Fragment fragment,String title) {
        
        if (likeFragment == null) {
        	 likeFragment = new LikeFragment();
        }
        
        manager = getSupportFragmentManager();
        transaction = manager.beginTransaction();
        transaction.replace(R.id.fragment,likeFragment,title);
        transaction.commit();
    }
}

// main_activity.xml
<?xml version="1.0" encoding="utf-8"?>
<android.support.constraint.ConstraintLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    xmlns:tools="http://schemas.android.com/tools"
    android:id="@+id/container"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    tools:context="com.lingshu.wangxuefeng.morepopular.MainActivity">

    <LinearLayout
        android:id="@+id/fragment"
        android:orientation="vertical"
        android:layout_width="match_parent"
        android:layout_height="match_parent">

    </LinearLayout>
</android.support.constraint.ConstraintLayout>


```

### 切换Activity

```
-------------- MainActivity.java --------------

Intent intent = new Intent(MainActivity.this,DestActivity.class);

String para = "para";

intent.putExtra("para",para);

startActivity(intent);


-------------- DestActivity.java --------------

onCreate() {
	Intent intent = getIntent();
}

```

### NSNotification & BroadCast

发送一个广播 ，名称为 UserInfoGet

```
Intent intent = new Intent();
intent.setAction("UserInfoGet");
XFApplication.getContext().sendBroadcast(intent);
```
接收一个广播，名称为 UserInfoGet

```
IntentFilter intentFilter = new IntentFilter();
intentFilter.addAction("UserInfoGet");

getActivity().registerReceiver(new BroadcastReceiver() {
    @Override
    public void onReceive(Context context, Intent intent) {
        loadData();
    }
},intentFilter);
```

### 剪贴板

> Android

```
String text = "balabala";

ClipboardManager clipboardManager = (ClipboardManager)getSystemService(CLIPBOARD_SERVICE);
ClipData data = ClipData.newPlainText("text",text);

clipboardManager.setPrimaryClip(data);

toast("copy invitation text success");
                
```

> iOS

```
UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    
pasteboard.string = string;

```

### UI布局

>iOS

frame、Autolayout为主，autoresize也还存在。可以使用xib进行布局，也可以使用代码，这两种差不多各50%。

>android

以xml布局为主，xml实现不了的(动态调整)才会使用代码进行调整。



#### LineLayout





### Support Library

Android 会有一些 Support Library ，比如常见的 v4 和 v7，为什么需要这些库呢？新版本的系统增加了一些就版本系统没有的新的内容，如果老的版本也想用这些内容，那就只能使用 Support Library。 iOS 官方并不会提供Support Library，但有些第三方实现了类似的功能，比如 UIStackView 从 iOS  9 生效，但是也有一些第三方库可以让 iOS 9 前的系统用上 UIStackView。



