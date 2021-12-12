5

I use following steps to remove old calico configs from kubernetes without kubeadm reset:

clear ip route: ip route flush proto bird
remove all calico links in all nodes ip link list | grep cali | awk '{print $2}' | cut -c 1-15 | xargs -I {} ip link delete {}
remove ipip module modprobe -r ipip
remove calico configs rm /etc/cni/net.d/10-calico.conflist && rm /etc/cni/net.d/calico-kubeconfig
restart kubelet service kubelet restart
After those steps all the running pods won't be connect, then I have to delete all the pods, then all the pods works. This has litter influence if you are using replicaset.