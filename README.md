优点：

利用IDEA的docker插件，在推送镜像的同时，可以在服务器docker直接拉取镜像并创建容器

缺点：

需要dockerfile


参考资料：

1. [在IntelliJ IDEA使用Docker运行Spring Cloud项目](https://www.cnblogs.com/hei12138/p/ideausedocker.html)

2. [Spring Boot 和 Docker 实现微服务部署](https://www2014.aspxhtml.com/post-9349)

按照资料2的步骤：

利用 maven 插件生成镜像文件
我们这里用到的 Maven 插件是 dockerfile-maven-plugin。

1. 在 pom 文件中添加上述插件依赖

```xml
<plugin>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-maven-plugin</artifactId>
</plugin>

<plugin>
    <groupId>com.spotify</groupId>
    <artifactId>dockerfile-maven-plugin</artifactId>
    <version>1.4.9</version>
    <executions>
        <execution>
            <id>tag-latest</id>
            <phase>deploy</phase>
            <goals>
                <goal>build</goal>
                <goal>tag</goal>
                <goal>push</goal>
            </goals>
            <configuration>
                <tag>latest</tag>
            </configuration>
        </execution>
        <execution>
            <id>tag-version</id>
            <phase>deploy</phase>
            <goals>
                <goal>build</goal>
                <goal>tag</goal>
                <goal>push</goal>
            </goals>
            <configuration>
                <tag>${project.version}</tag>
            </configuration>
        </execution>
    </executions>
    
</plugin>

```

2、这个 maven 插件是依赖于 Dockerfile 文件的，所以使用命令之前需要先手动创建 Dockerfile 文件，注意这个 Dockerfile 文件要和 pom.xml 文件同级，简单的 Dockerfile 内容如下：

```dockerfile
FROM openjdk:8-jdk-alpine
VOLUME /tmp
COPY target/docker-sample-1.0-SNAPSHOT.jar app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
```

简单解释一下：

先从中央仓库或者你配置的代理仓库（如阿里云镜像仓库）拉取 openjdk 镜像；
然后设置一个挂载点；
拷贝 target 目录下的 Spring boot 项目运行包，并改名为 app.jar;
设置启动命令 java -jar app.jar
3、然后使用命令 sudo mvn package dockerfile:build 就可以生成镜像到本地仓库了，生成后的镜像如下：

这一步翻译为 docker 命令的话就是下面两条：

```docker
docker build -t registry.cn-beijing.aliyuncs.com/fengzheng/kite:1.0-SNAPSHOT . 
docker build -t registry.cn-beijing.aliyuncs.com/fengzheng/kite:latest
```

4、之后根据生成的镜像，就可以以 docker 方式启动服务了

```docker
docker run -d -p 7000:7000 registry.cn-beijing.aliyuncs.com/fengzheng/kite:latest
```

将镜像推送到阿里云 docker 仓库
访问 https://dev.aliyun.com/search.html，然后随意输入一个镜像名称，例如 redis，如果你没有注册过，阿里云便会调到登录注册页，之后按照提示注册即可。

注册成功后，到镜像管理界面，会提示你输入镜像仓库服务的密码，也就是下方配置文件中的 Registry登录密码。

注册成功后，设置一个命名空间，并在命名空间下新建一个仓库。例如本例中我设置的命名空间是fengzheng,仓库名称为 kite。

> **注意:** 这个仓库名称是自动创建出来的，`<repository>`标签下是仓库域名+命名空间+{自定义的仓库名称}

之后，在 pom.xml 文件中 plugin 节点增加如下配置：

```xml
<configuration>
        <username>阿里云账号名</username>
        <!--在容器镜像服务控制台"设置Registry登录密码"-->
        <password>Registry登录密码</password>
        <!--registry.cn-hangzhou.aliyuncs.com/namespace/repositoryname-->
        <repository>registry.cn-beijing.aliyuncs.com/fengzheng/kite</repository>
        <tag>latest</tag>
        <buildArgs>              
            <JAR_FILE>${project.build.finalName}.jar</JAR_FILE>
        </buildArgs>
</configuration>
```

设置好用户名和密码，仓库地址等参数，因为是私有仓库，所以需要用户名和密码。

然后运行命令，将以 latest 和 ${project.version} 为 tag 的镜像推送到阿里云镜像仓库。

sudo mvn dockerfile:push 
或者，运行命令，发布某一个指定 tag 的镜像。

sudo mvn dockerfile:push@tag-version
或
sudo mvn dockerfile:push@tag-latest