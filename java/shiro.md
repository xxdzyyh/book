## shiro

* [知乎专栏](https://zhuanlan.zhihu.com/p/54176956)
* [翻译](https://blog.csdn.net/wanliangsoft/article/details/86533754)

#### 授权过程

1. 首先调用 Subject.login(token) 进行登录，其会自动委托给 SecurityManager

2. SecurityManager 负责真正的身份验证逻辑；它会委托给 Authenticator 进行身份验证；

3. Authenticator 才是真正的身份验证者，Shiro中核心的身份认证入口点，此处可以自定义插入自己的实现；

4. Authenticator 可能会委托给相应的 AuthenticationStrategy 进 行多 Realm 身份验证，默认 ModularRealmAuthenticator 会调用 AuthenticationStrategy 进行多 Realm 身份验证；

5. Authenticator 会把相应的 token 传入 Realm，从 Realm 获取 身份验证信息，如果没有返回/抛出异常表示身份验证失败了。此处 可以配置多个Realm，将按照相应的顺序及策略进行访问。

> 实现流程

1. 获取当前的Subject,调用 `SecurityUtils.getSubject()`

2. 调用 `Subject.isAuthenticated()`判断当前的用户是否已经认证
3. 没有认证，则把用户名和密码封装为`UsernamePasswordToken`对象,调用`Subject.login(token)`
4. 实现自定义Realm的 `doGetAuthenticationInfo`方法，返回账号的信息（一般查数据库获取用户名对应的密码）
5. shiro 完成密码比对。

```
SimpleAccountRealm simpleAccountRealm = new SimpleAccountRealm();

// 账号 wmyskxz 密码 123456 Roles ["admin", "user"]
simpleAccountRealm.addAccount("wmyskxz", "123456", "admin", "user");

// 1.构建SecurityManager环境
DefaultSecurityManager defaultSecurityManager = new DefaultSecurityManager();
defaultSecurityManager.setRealm(simpleAccountRealm);

// 2.主体提交认证请求
SecurityUtils.setSecurityManager(defaultSecurityManager); // 设置SecurityManager环境
Subject subject = SecurityUtils.getSubject(); // 获取当前主体

UsernamePasswordToken token = new UsernamePasswordToken("wmyskxz", "123456");
subject.login(token); // 登录

// subject.isAuthenticated()方法返回一个boolean值,用于判断用户是否认证成功
System.out.println("isAuthenticated:" + subject.isAuthenticated()); // 输出true
// 判断subject是否具有admin和user两个角色权限,如没有则会报错
subject.checkRoles("admin","user");
// subject.checkRole("xxx"); // 报错
```



```
AuthCheckGatewayFilterFactory.java
private Mono<Void> doLogout(ServerWebExchange exchange) {
	
	getSubject(sessionId).logout();
}


// principals = null
// 导致没有执行下面的logout
// if (authc instanceof LogoutAware) {
      ((LogoutAware) authc).onLogout(principals);
   }
//
//
PrincipalCollection principals = subject.getPrincipals();
if (principals != null && !principals.isEmpty()) {
    if (log.isDebugEnabled()) {
        log.debug("Logging out subject with primary principal {}", principals.getPrimaryPrincipal());
    }
    Authenticator authc = getAuthenticator();
    if (authc instanceof LogoutAware) {
        ((LogoutAware) authc).onLogout(principals);
    }
}
```



### isPermitted、checkPermission

checkPermission 最终的判断也是通过 isPermitted 进行的，这么看两者的区别就是返回值不同，一个返回boolean，一个抛异常。

```
public boolean isPermitted(PrincipalCollection principals, Permission permission) {
    AuthorizationInfo info = getAuthorizationInfo(principals);
    return isPermitted(permission, info);
}

//visibility changed from private to protected per SHIRO-332
protected boolean isPermitted(Permission permission, AuthorizationInfo info) {
    Collection<Permission> perms = getPermissions(info);
    if (perms != null && !perms.isEmpty()) {
        for (Permission perm : perms) {
            if (perm.implies(permission)) {
                return true;
            }
        }
    }
    return false;
}
```



```
public void checkPermission(PrincipalCollection principal, Permission permission) throws AuthorizationException {
    AuthorizationInfo info = getAuthorizationInfo(principal);
    checkPermission(permission, info);
}

protected void checkPermission(Permission permission, AuthorizationInfo info) {
    if (!isPermitted(permission, info)) {
        String msg = "User is not permitted [" + permission + "]";
        throw new UnauthorizedException(msg);
    }
}
```



### 权限缓存

在自定义的 realm 里我们会实现`doGetAuthorizationInfo`方法，然后其他地方调用 `AuthorizingRealm.getAuthorizationInfo`,

`getAuthorizationInfo`里面会判断是否有AuthorizationInfo的缓存。

```
Cache<Object, AuthorizationInfo> cache = getAvailableAuthorizationCache();
if (cache != null) {
    if (log.isTraceEnabled()) {
        log.trace("Attempting to retrieve the AuthorizationInfo from cache.");
    }
    Object key = getAuthorizationCacheKey(principals);
    info = cache.get(key);
    if (log.isTraceEnabled()) {
        if (info == null) {
            log.trace("No AuthorizationInfo found in cache for principals [" + principals + "]");
        } else {
            log.trace("AuthorizationInfo found in cache for principals [" + principals + "]");
        }
    }
}

if (info == null) {
    // Call template method if the info was not found in a cache
    info = doGetAuthorizationInfo(principals);
    // If the info is not null and the cache has been created, then cache the authorization info.
    if (info != null && cache != null) {
        if (log.isTraceEnabled()) {
            log.trace("Caching authorization info for principals: [" + principals + "].");
        }
        Object key = getAuthorizationCacheKey(principals);
        cache.put(key, info);
    }
}
```



```
public class MyRealm extends AuthorizingRealm {
	 @Override
    protected AuthorizationInfo doGetAuthorizationInfo(PrincipalCollection principalCollection) {
    	SimpleAuthorizationInfo simpleAuthenticationInfo = new SimpleAuthorizationInfo();
    	
    	simpleAuthenticationInfo.addRole("admin");
    	simpleAuthenticationInfo.addStringPermission("createApp");
    	
    	return simpleAuthenticationInfo;
    }
}
```





### shiroWeb vs shiro

非Web

* SimpleSession

#### Web

* ShiroFilterFactoryBean

* HttpSession








```
class ModifyHeaderRequest extends HttpServletRequestWrapper {

    private String userName;

    public ModifyHeaderRequest(HttpServletRequest request) {
        super(request);
    }

    public ModifyHeaderRequest(HttpServletRequest request,String userName) {
        super(request);
        this.userName = userName;
    }

    public String getHeader(String name) {
        String value = super.getHeader(name);
        if (StringUtil.isBlank(value) && name.equalsIgnoreCase(USERNAME_HEADER)) {
            return this.userName;
        }
        return value;
    }
}
```



```
package com.buginsight.springboot.dao;

import com.buginsight.springboot.entity.AuthSessionInfo;
import org.apache.ibatis.annotations.*;
import org.springframework.stereotype.Repository;

@Mapper
@Repository
public interface AuthSessionDao {

    @Insert("insert into auth_session_token(session_id,token,start_time,expired_time,user_name,host) values(#{sessionId},#{token},FROM_UNIXTIME(#{startTime}/1000),FROM_UNIXTIME(#{expiredTime}/1000),#{userName},#{host})")
    void insertSession(@Param("sessionId") String sessionId,
                       @Param("token") String token,
                       @Param("startTime") long startTime,
                       @Param("expiredTime") long expiredTime,
                       @Param("userName") String userName,
                       @Param("host") String host
                       );

    @Delete("delete from auth_session_token where session_id = #{sessionId}")
    void deleteSession(@Param("sessionId") String sessionId);

    @Select("select session_id as sessionId,unix_timestamp(expired_time)*1000 as expiredTime," +
            "unix_timestamp(start_time)*1000 as startTime, " +
            "user_name as userName," +
            "host, " +
            "token " +
            "from auth_session_token where session_id = #{sessionId}")
    AuthSessionInfo findAuthSessionTokenBySessionId(String sessionId);
}
```