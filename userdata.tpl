#!/bin/bash
# Install AWS EFS Utilities
yum install -y amazon-efs-utils
yum update -y
yum install -y docker
service docker start
usermod -aG docker ec2-user
# Mount EFS
efs_mount_point_1=/var/lib/docker/volumes/jenkins_home
mkdir -p $efs_mount_point_1
efs_id="${efs_id}"
mount -t efs $efs_id:/ $efs_mount_point_1
# Edit fstab so EFS automatically loads on reboot
echo $efs_id:/ $efs_mount_point_1 efs defaults,_netdev 0 0 >> /etc/fstab
