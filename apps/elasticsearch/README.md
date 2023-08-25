1. mkdir /data/es_cluster/{es01,es02,es03}

2. create network subnet

   docker network create --subnet 172.25.0.1/24 elastic

   ```yml
    networks:
    elastic:
        external: true
    ```

    ```yml
     networks:
      elastic:
        ipv4_address: 172.25.0.5   
    ```


