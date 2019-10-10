1. File -> New -> Create Android Project
	
	![xxx](https://raw.githubusercontent.com/xxdzyyh/static/master/android/2019-01-22-11-30-58.png)

2. 修改 app/build.gradle
	
	* apply plugin: 'com.android.application' -> apply plugin: 'com.android.library'
	* 删除 applicationId，App Module 才可以定义
	
	![修改前](https://github.com/xxdzyyh/static/blob/master/android/2019-01-22-11-33-03.png?raw=true)
	
	修改后
	
	![修改后](https://github.com/xxdzyyh/static/blob/master/android/2019-01-22-11-34-17.png?raw=true)
	
3. Build -> Make Project
	
	app/build/outputs/aar
	
4. 其他项目导入
	
	* File -> New -> Import Module...
	* Open Module Setting -> Dependencies -> + -> Module Dependecy