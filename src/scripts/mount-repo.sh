mkdir -p /repo
mount -t 9p -o trans=virtio,version=9p2000.L hostrepo /repo
cd /repo