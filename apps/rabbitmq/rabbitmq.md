#### 常规概念

在 RabbitMQ 集群中，节点类型可以分为两种:

1. 内存节点：元数据存放于内存中。为了重启后能同步数据，内存节点会将磁盘节点的地址存放于磁盘之中，除此之外，如果消息被持久化了也会存放于磁盘之中，因为内存节点读写速度快，一般客户端会连接内存节点。
2. 磁盘节点：元数据存放于磁盘中（默认节点类型），需要保证至少一个磁盘节点，否则一旦宕机，无法恢复数据，从而也就无法达到集群的高可用目的。

元数据，指的是包括队列名字属性、交换机的类型名字属性、绑定信息、vhost等基础信息，不包括队列中的消息数据。


RabbitMQ 中的集群主要有两种模式：普通集群模式和镜像队列模式


1. 普通集群模式
在普通集群模式下，集群中各个节点之间只会相互同步元数据，也就是说，消息数据不会被同步。那么问题就来了，假如我们连接到 A 节点，但是消息又存储在 B 节点又怎么办呢？
不论是生产者还是消费者，假如连接到的节点上没有存储队列数据，那么内部会将其转发到存储队列数据的节点上进行存储。虽然说内部可以实现转发，但是因为消息仅仅只是存储在一个节点，那么假如这节点挂了，消息是不是就没有了？这个问题确实存在，所以这种普通集群模式并没有达到高可用的目的。

2. 镜像队列模式
镜像队列模式下，节点之间不仅仅会同步元数据，消息内容也会在镜像节点间同步，可用性更高。这种方案提升了可用性的同时，因为同步数据之间也会带来网络开销从而在一定程度上会影响到性能。


#### 基础操作

```
# 添加用户
 rabbitmqctl add_user admin metaports

# 设置用户角色，分配操作权限
rabbitmqctl set_user_tags admin administrator

# 为用户添加资源权限(授予访问虚拟机根节点的所有权限)
rabbitmqctl set_permissions -p "/" admin ".*" ".*" ".*"

# 管理后台启用

rabbitmq-plugins enable rabbitmq_management
```


单机 dokcer-compose 集群部署

1. 创建可用网络

    docker network create --subnet 172.25.0.1/24 rabbitmq


    mq2:

    rabbitmqctl stop_app
    rabbitmqctl reset
    rabbitmqctl join_cluster rabbit@mq1
    rabbitmqctl start_app

    mq3:
    rabbitmqctl stop_app
    rabbitmqctl reset
    rabbitmqctl join_cluster --ram rabbit@mq1
    rabbitmqctl start_app


更改节点类型

在主节点执行:

rabbitmqctl -n rabbit@mq2 stop_app
rabbitmqctl forget_cluster_node rabbit@mq2


    rabbitmqctl stop_app
    rabbitmqctl reset
    rabbitmqctl join_cluster --ram rabbit@mq1   # 这里加入 --ram 参数即可
    rabbitmqctl start_app


需要注意的是，到这里启动的集群只是默认的普通集群，如果想要配置成镜像集群，则需要执行以下命令：

    rabbitmqctl set_policy ha-11 '^11' '{"ha-mode":"all","ha-sync-mode":"automatic"}'

    rabbitmqctl set_policy ha-11 '.*' '{"ha-mode":"all","ha-sync-mode":"automatic"}'