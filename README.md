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

#### Example EOS configuration

```
route-map CANARY permit 10
   set ip next-hop unchanged
!
router bgp 65100
   bgp listen range 172.17.0.0/16 peer-group CANARY remote-as 65000
   neighbor CANARY peer group
   neighbor CANARY remote-as 65000
   neighbor CANARY ebgp-multihop
   neighbor CANARY route-map CANARY out
   neighbor 169.254.0.0 remote-as 65100
   network 1.1.1.103/32
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
2021-05-12T22:52:49Z [ROUTE] 1.1.1.109/32 via 169.254.0.0 aspath [65100] attrs [{Origin: ?}]
2021-05-12T22:52:49Z [ROUTE] 1.1.1.207/32 via 169.254.0.0 aspath [65100] attrs [{Origin: ?}]
2021-05-12T22:52:49Z [ROUTE] 1.1.1.224/32 via 169.254.0.0 aspath [65100] attrs [{Origin: ?}]
```

#### Monitor [json formatted]

```bash
docker exec gobgp gobgp monitor global rib --current -j
[{"nlri":{"prefix":"1.1.1.80/32"},"age":1620859753,"best":false,"attrs":[{"type":1,"value":2},{"type":2,"as_paths":[{"segment_type":2,"num":1,"asns":[65100]}]},{"type":3,"nexthop":"169.254.0.0"}],"stale":false,"source-id":"1.1.1.103","neighbor-ip":"1.1.1.103"}]
[{"nlri":{"prefix":"1.1.1.125/32"},"age":1620859753,"best":false,"attrs":[{"type":1,"value":2},{"type":2,"as_paths":[{"segment_type":2,"num":1,"asns":[65100]}]},{"type":3,"nexthop":"169.254.0.0"}],"stale":false,"source-id":"1.1.1.103","neighbor-ip":"1.1.1.103"}]
[{"nlri":{"prefix":"1.1.1.205/32"},"age":1620859753,"best":false,"attrs":[{"type":1,"value":2},{"type":2,"as_paths":[{"segment_type":2,"num":1,"asns":[65100]}]},{"type":3,"nexthop":"169.254.0.0"}],"stale":false,"source-id":"1.1.1.103","neighbor-ip":"1.1.1.103"}]
```

