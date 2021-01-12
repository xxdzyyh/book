## SpringBoot 

Spring Boot是由Pivotal团队提供的全新框架，其设计目的是用来简化新Spring应用的初始搭建以及开发过程。该框架使用了特定的方式来进行配置，从而使开发人员不再需要定义样板化的配置。通过这种方式，Spring Boot致力于在蓬勃发展的快速应用开发领域(rapid application development)成为领导者。



### SpringBoot Starter

starter可以简单的认为就是一个第三方。

只是说这个第三方将自己依赖的东西都捆绑到了一起，这样我们就不需要去配置这些第三方。

SpringBoot提供的starter以`spring-boot-starter-xxx`的方式命名的。

官方建议自定义的starter使用`xxx-spring-boot-starter`命名规则。以区分SpringBoot生态提供的starter。



其实非常类似于 iOS 工程的依赖。



SpringBoot 

bootstrap.yml（bootstrap.properties）用来在程序引导时执行，应用于更加早期配置信息读取，如可以使用来配置application.yml中使用到参数等

application.yml（application.properties) 应用程序特有配置信息，可以用来配置后续各个模块中需使用的公共参数等。

bootstrap.yml 先于 application.yml 加载