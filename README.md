# GoBGP Listener

## Setup

### Build/Export
```bash
docker build --no-cache -t gobgp .
docker save gobgp:latest | gzip > gobgp.tar.gz
scp gobgpd.conf gobgp.tar.gz admin@switch:/mnt/flash
```

### On switch

Note: log-level and log-plain are optional

```bash
docker load < /mnt/flash/gobgp.tar.gz

docker run -it --rm --name gobgp \
    -v /mnt/flash/gobgpd.conf:/gobgpd.conf gobgp:latest \
    --log-level=debug --log-plain
```

### ...And from another session

#### Get neighbors...

```bash
docker exec gobgp gobgp neighbor
Peer         AS  Up/Down State       |#Received  Accepted
1.1.1.103 65103 00:00:03 Establ      |        5         5
```

#### To monitor

```bash
docker exec gobgp gobgp monitor global rib --current
2021-05-06T23:13:26Z [ROUTE] 1.1.1.105/32 via 1.1.1.103 aspath [65103 65104] attrs [{Origin: ?}]
2021-05-06T23:13:26Z [ROUTE] 1.1.1.103/32 via 1.1.1.103 aspath [65103] attrs [{Origin: i}]
2021-05-06T23:13:26Z [ROUTE] 1.1.1.104/32 via 1.1.1.103 aspath [65103 65104] attrs [{Origin: i}]
```

#### Monitor [json formatted]

```bash
docker exec gobgp gobgp monitor global rib --current -j
[{"nlri":{"prefix":"1.1.1.104/32"},"age":1620342775,"best":false,"attrs":[{"type":1,"value":0},{"type":2,"as_paths":[{"segment_type":2,"num":2,"asns":[65103,65104]}]},{"type":3,"nexthop":"1.1.1.103"}],"stale":false,"source-id":"1.1.1.103","neighbor-ip":"1.1.1.103"}]
[{"nlri":{"prefix":"1.1.1.105/32"},"age":1620342775,"best":false,"attrs":[{"type":1,"value":2},{"type":2,"as_paths":[{"segment_type":2,"num":2,"asns":[65103,65104]}]},{"type":3,"nexthop":"1.1.1.103"}],"stale":false,"source-id":"1.1.1.103","neighbor-ip":"1.1.1.103"}]
[{"nlri":{"prefix":"1.1.1.103/32"},"age":1620342775,"best":false,"attrs":[{"type":1,"value":0},{"type":2,"as_paths":[{"segment_type":2,"num":1,"asns":[65103]}]},{"type":3,"nexthop":"1.1.1.103"}],"stale":false,"source-id":"1.1.1.103","neighbor-ip":"1.1.1.103"}]
```

