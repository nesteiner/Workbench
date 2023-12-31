
# Table of Contents

1.  [Introduction](#org0ea099e)
    1.  [第一次进入应用](#org2082fae)
    2.  [主页](#org5bd64b0)
    3.  [待办清单](#org9fba1b3)
    4.  [习惯打卡](#org2491012)
    5.  [samba 文件共享](#org9cc1681)
    6.  [其他操作](#org80977ea)
    7.  [其他](#orgac5dc41)
2.  [Install](#orga4faf67)
    1.  [backend](#org3706cc7)
        1.  [Requirement](#orgc6cf288)
        2.  [Build](#orgb67ed95)
        3.  [Run](#org7de5987)
    2.  [frontend](#org9d6e969)
        1.  [Requiremenet](#orge4f277f)
        2.  [Build](#orgc1ef86d)
3.  [缺陷](#org88aa472)
4.  [下一步](#org5626776)
    1.  [Sidebar navigator](#org9e3be9d)
    2.  [GoRouter](#org7a8a7ad)



<a id="org0ea099e"></a>

# Introduction

这个项目是个人拿来玩的，由于个人要用到多种学习工具，比如番茄钟啊，待办清单呐，习惯打卡啊，  
这些东西都只是一个单一的功能，没有软件将他们集成在一起，搞得我每次都要不停的切换页面，因此我需要一个一站式工作台来解决这个痛点  
而有时候我不在电脑前操作，需要在手机上布置任务，从而又有了适配多个平台的需求  
市面上有一个类似的应用，叫滴答清单，可惜这玩意要钱，秉承着能白嫖就绝不充钱的原则，我就闲得蛋疼开发出了这么一款应用，顺带作为我的毕业设计，历时三个月的开发终于开发完了，或许吧  

话不多说，这里以linux平台的应用为例，看看怎么操作把  


<a id="org2082fae"></a>

## 第一次进入应用



https://github.com/nesteiner/Workbench/assets/46296608/bb7299f5-dcd4-46ac-b16c-286a0d0b6828



<a id="org5bd64b0"></a>

## 主页



https://github.com/nesteiner/Workbench/assets/46296608/9fcc38ed-eab5-42fb-a2c2-e9030e6ee02c




<a id="org9fba1b3"></a>

## 待办清单


https://github.com/nesteiner/Workbench/assets/46296608/074e6bf1-f5e9-4d19-bbdc-13618af70c0a



<a id="org2491012"></a>

## 习惯打卡


https://github.com/nesteiner/Workbench/assets/46296608/f265d144-f1a7-4665-b868-64837f31689e



<a id="org9cc1681"></a>

## samba 文件共享



https://github.com/nesteiner/Workbench/assets/46296608/a6e5fc65-cc04-4807-966a-4eec6beffe92





<a id="org80977ea"></a>

## 其他操作

需要登出了，就点击侧边的登出按扭  
需要重置服务器设置，就点击X按扭，重新进入第一次加载的页面  


<a id="orgac5dc41"></a>

## 其他

这个应用还不能进入生产模式，我还在改 bug，可能需要重构前端代码和后端代码，也有可能换到 Ktor 架构  


<a id="orga4faf67"></a>

# Install


<a id="org3706cc7"></a>

## backend


<a id="orgc6cf288"></a>

### Requirement

Openjdk-17  


<a id="orgb67ed95"></a>

### Build

如果是第一次加载应用，你可以在 `app/src/main/resource/application.yaml` 中配置 `app.initialize` 为 `true`  
否则e设置为 `false` ，这个选项是为了初始化数据而设置的  
在 `backend` 目录下，运行以下命令  

    ./gradlew :bootJar


<a id="org7de5987"></a>

### Run

    java -jar build/libs/workbench-0.0.1-SNAPSHOT.jar


<a id="org9d6e969"></a>

## frontend


<a id="orge4f277f"></a>

### Requiremenet

-   Flutter 最新版本
-   Rust stable 最新版本


<a id="orgc1ef86d"></a>

### Build

在 frontend 目录下  

为安卓手机构建应用  

    flutter build apk --release

在 Linux 平台下  

    flutter build linux --release

将 `build/linux/x64/release/bundle` 目录提取出来，创建如下 Desktop 文件到 `~/.local/share/applications/` 中  

    [Desktop Entry]
    Name=Workbench frontend
    Exec=/path/to/release/bundle/frontend
    Terminal=false
    Type=Application
    Icon=这个自己设置路径
    Comment=The all-in-one workbench for pomodoro, todolist, daily-attendance and so on
    Categories=Office;Utility;

在 Windows 平台下  

    flutter build windows --release


<a id="org88aa472"></a>

# 缺陷

-   并发需求
-   没有同步机制


<a id="org5626776"></a>

# 下一步


<a id="org9e3be9d"></a>

## Sidebar navigator

1.  use controller


<a id="org7a8a7ad"></a>

## GoRouter

