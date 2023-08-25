    sudo docker exec -i mq3 rabbitmq-plugins enable rabbitmq_management
    sudo docker exec -i mq2 rabbitmq-plugins enable rabbitmq_management
    sudo docker exec -i mq1 rabbitmq-plugins enable rabbitmq_management

    sudo docker exec -i mq2 rabbitmqctl stop_app
    sudo docker exec -i mq2 rabbitmqctl reset
    sudo docker exec -i mq2 rabbitmqctl join_cluster --ram rabbit@mq1
    sudo docker exec -i mq2 rabbitmqctl start_app


    sudo docker exec -i mq3 rabbitmqctl stop_app
    sudo docker exec -i mq3 rabbitmqctl reset
    sudo docker exec -i mq3 rabbitmqctl join_cluster --ram rabbit@mq1
    sudo docker exec -i mq3 rabbitmqctl start_app
