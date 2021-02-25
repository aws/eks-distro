# EKS-D v1-19-eks-1 Release

Highlights of the Kubernetes 1.19 release include Ingress API and Pod Topology
Spread reaching stable status, EndpointSlices being enabled by default, and
immutable Secrets and ConfigMaps. A [change log](CHANGELOG-v1-19-eks-1.md) is available
describing the patches and versions included in this release.

The [EKS-D v1-19-eks-1](https://distro.eks.amazonaws.com/kubernetes-1-19/kubernetes-1-19-eks-1.yaml)
release manifest defines the release used in EKS-D.

```yaml
apiVersion: distro.eks.amazonaws.com/v1alpha1
kind: Release
metadata:
  creationTimestamp: null
  name: kubernetes-1-19-eks-1
spec:
  channel: 1-19
  number: 1
status:
  components:
  - assets:
    - arch:
      - arm64
      archive:
        sha256: c8b38996683ed32c488e73503a210e51fe5101fe749c5393041af27b31cd5c75
        sha512: 65ea408c9645d0adf0d95fe93c9355d903cb940890f9c36253b4a73fc2eb6c9bd2cba5a31ef9fb7d73cb288e24b4df615168873ac199867de34e8e87f4b80224
        uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/1/artifacts/kubernetes/v1.19.6/kubernetes-client-linux-arm64.tar.gz
      description: Kubernetes client tarball for linux/arm64
      name: kubernetes-client-linux-arm64.tar.gz
      os: linux
      type: Archive
    - arch:
      - arm64
      archive:
        sha256: ba728d44ef152e5deed5263929d9a3a3391403935b44d08969ffe8831ef4e9d8
        sha512: e9c7436e3694fc92646d8d9f5debef23f6a0cee05ab12f315b16a51fab9de511c5e0924330543e1d4659dac302b50f95ff455f88647adaf3a0f43bd991e28e57
        uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/1/artifacts/kubernetes/v1.19.6/kubernetes-server-linux-arm64.tar.gz
      description: Kubernetes server tarball for linux/arm64
      name: kubernetes-server-linux-arm64.tar.gz
      os: linux
      type: Archive
    - arch:
      - arm64
      archive:
        sha256: d96bdc4517e9f576a5924428e0f3178fe5a6ff7e6c030331220a4e7fcc65bf0a
        sha512: 829312f19b33d3b11413a9761e71652d8ddc6ccbb009401933e70e9bdb8b9e67d015cca4eeff4f5e7b98ffbd5dbdfa0f11d1d01840f2aa30e813be5a49d71c3b
        uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/1/artifacts/kubernetes/v1.19.6/kubernetes-node-linux-arm64.tar.gz
      description: Kubernetes node tarball for linux/arm64
      name: kubernetes-node-linux-arm64.tar.gz
      os: linux
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: 881f6ea54c9fe242cb6f1346415a2d284d4e21dac844631021c0bad231b1830f
        sha512: 8db236495ff3728fcf46acd8370be93ed8f8f16ce049a85946f285776148ae6c901cfe2908ef40f51bdd5a109c2e6eb4f89c37709cc8c82bd7418ddbcedbabcd
        uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/1/artifacts/kubernetes/v1.19.6/kubernetes-client-linux-amd64.tar.gz
      description: Kubernetes client tarball for linux/amd64
      name: kubernetes-client-linux-amd64.tar.gz
      os: linux
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: ef1966701b9fe8a083d3def007f15f96da9e855f53e8e67f00af0a818a5f6b8c
        sha512: 055394ec66c8ac98085bcb45c8670c0916afb804d2f7aac25bfb2e8e2147cd25ff674507e7c51984fb52a51e27544da22c535f811ddd453635211486e4c9ecee
        uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/1/artifacts/kubernetes/v1.19.6/kubernetes-server-linux-amd64.tar.gz
      description: Kubernetes server tarball for linux/amd64
      name: kubernetes-server-linux-amd64.tar.gz
      os: linux
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: 3ca09a8768d247fd6408d9a8253295601ed493068b3b49ce49895585b6464647
        sha512: d358a3a324b0611e4e9610a4b417cb11a84cddd0b7dea41dedf79488cf6e011deeeef5e7494b52576059cf8c2ca976f604b4ae8d10a148aab54aa3a1025f1b69
        uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/1/artifacts/kubernetes/v1.19.6/kubernetes-node-linux-amd64.tar.gz
      description: Kubernetes node tarball for linux/amd64
      name: kubernetes-node-linux-amd64.tar.gz
      os: linux
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: b5e61bcc3be99b601bfb05a2c4b8f998adad6eddbd71457b26b9bbc53a476f4d
        sha512: 9767ae9b66aaca4325ab0f614411a56fbd51b99e5e812e2c27ef7a8bef7dcee9af3a631d3cea595d99fd6ad96771f08ca4719fe86800a6cb1c0f49b68b4042c2
        uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/1/artifacts/kubernetes/v1.19.6/kubernetes-client-windows-amd64.tar.gz
      description: Kubernetes client tarball for windows/amd64
      name: kubernetes-client-windows-amd64.tar.gz
      os: windows
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: eec94012ff95d671db6ec89c78a508776201b4a025f2d78226942829f78bbeb3
        sha512: 907028018df4027f9e9a26f4ac1b98cacb3647f8a6324034add778dfde7887fa9c1d87b7f7d9e0af7ab8ea66c3fa7abddec07380cac43dc0514f437865de139f
        uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/1/artifacts/kubernetes/v1.19.6/kubernetes-node-windows-amd64.tar.gz
      description: Kubernetes node tarball for windows/amd64
      name: kubernetes-node-windows-amd64.tar.gz
      os: windows
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: 85ef73365548857876b37e93e676535f39ad390355c69da6de346577b3fe0760
        sha512: 27f09aeb73a70429fe1ad34d63393411103ff0694e94159a6b96043bd11067b4c465dc72ee115c95dc3a27453686be3ad9b087dbfbe930bd3bfb2a80ed2d9753
        uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/1/artifacts/kubernetes/v1.19.6/kubernetes-client-darwin-amd64.tar.gz
      description: Kubernetes client tarball for darwin/amd64
      name: kubernetes-client-darwin-amd64.tar.gz
      os: darwin
      type: Archive
    - arch:
      - amd64
      - arm64
      description: kube-apiserver container image
      image:
        uri: /kubernetes/kube-apiserver:v1.19.6-eks-1-19-1
      name: kube-apiserver-image
      os: linux
      type: Image
    - arch:
      - amd64
      - arm64
      description: kube-controller-manager container image
      image:
        uri: /kubernetes/kube-controller-manager:v1.19.6-eks-1-19-1
      name: kube-controller-manager-image
      os: linux
      type: Image
    - arch:
      - amd64
      - arm64
      description: kube-scheduler container image
      image:
        uri: /kubernetes/kube-scheduler:v1.19.6-eks-1-19-1
      name: kube-scheduler-image
      os: linux
      type: Image
    - arch:
      - amd64
      - arm64
      description: kube-proxy container image
      image:
        uri: /kubernetes/kube-proxy:v1.19.6-eks-1-19-1
      name: kube-proxy-image
      os: linux
      type: Image
    - arch:
      - amd64
      - arm64
      description: pause container image
      image:
        uri: /kubernetes/pause:v1.19.6-eks-1-19-1
      name: pause-image
      os: linux
      type: Image
    - arch:
      - arm64
      archive:
        sha256: 6738ad3d4bdd80873c389c22788c95002ae50400e3a3aebdbabb8513f7710b02
        sha512: ea7f7596f2ac1633cd4218c2f08712f64790a39ecf398877e226fcb61714c763736e79954d8b8f995f4d129e9222e86abdb4f23af7164bc0468d1b200ce4643e
        uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/1/artifacts/kubernetes/v1.19.6/bin/linux/arm64/kube-apiserver
      description: kube-apiserver binary for linux/arm64
      name: bin/linux/arm64/kube-apiserver
      os: linux
      type: Archive
    - arch:
      - arm64
      archive:
        sha256: 653e8067abf371ac02a30f63d5ca9865dd71cdcd51cfb54e987224cf82b8a06d
        sha512: cef74b3180d3b028b89b5ab0eeeb93919a03e83d83655e9954a49a5ae8f5894c024d99c2153f0a18a2d49b7ecf036c4a83868fa515d9c4a01442831b4eec3ad4
        uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/1/artifacts/kubernetes/v1.19.6/bin/linux/arm64/kube-controller-manager
      description: kube-controller-manager binary for linux/arm64
      name: bin/linux/arm64/kube-controller-manager
      os: linux
      type: Archive
    - arch:
      - arm64
      archive:
        sha256: 5051926d0bef63b90ff04177d23d26b01dcdc859ee42b509f5ab69c5ff55cb76
        sha512: b33d99678ae03df21254173e7c784a648b1ea94e5a928f91434a56ccbc88e71069749f4f68a7eeab2fe9d8fcb8d063d44d8c0b0f0dd9b0151fb12a62099d1c84
        uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/1/artifacts/kubernetes/v1.19.6/bin/linux/arm64/kube-proxy
      description: kube-proxy binary for linux/arm64
      name: bin/linux/arm64/kube-proxy
      os: linux
      type: Archive
    - arch:
      - arm64
      archive:
        sha256: a08a44da0afd0995152abc130e2e48645acfffceb2c2541668a7bf4a70c4a15c
        sha512: 48d97a7da4919f40da10d6da67f94d807db7a8eb96a68a3acd6fdaeffe997b1bd21f2b37017021a2c6a358cdba2ec7744686090086c1fd032600c09d758bc037
        uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/1/artifacts/kubernetes/v1.19.6/bin/linux/arm64/kube-scheduler
      description: kube-scheduler binary for linux/arm64
      name: bin/linux/arm64/kube-scheduler
      os: linux
      type: Archive
    - arch:
      - arm64
      archive:
        sha256: 89c872c1d37e205b7038da9a8bb9569015ebea1f7424e98b62da5b38514536c6
        sha512: d26748c87bdd09490931e07f71411cb71b71b7a7c42094281bda5efda8e3d1dea3ec0a487c92102d3d2d5e3dac095be7fbbbdf021240da13c77634bfc231425e
        uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/1/artifacts/kubernetes/v1.19.6/bin/linux/arm64/kubectl
      description: kubectl binary for linux/arm64
      name: bin/linux/arm64/kubectl
      os: linux
      type: Archive
    - arch:
      - arm64
      archive:
        sha256: b9e5c5fc82fc32436ee630686fdecd13cedf4e9d130ae9cd34e97d9c369bf7cc
        sha512: 42818e41a43c02d4efef03d0e1a7a80cc412a3f9e18725e67adc042852819e5942c24a70d274d4dc488a0bf1dbc76a133b6c2adbdb0ac5d40f7b233a2de7242d
        uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/1/artifacts/kubernetes/v1.19.6/bin/linux/arm64/kubelet
      description: kubelet binary for linux/arm64
      name: bin/linux/arm64/kubelet
      os: linux
      type: Archive
    - arch:
      - arm64
      archive:
        sha256: 857b70c5276b2bb2da433a8b2e3fd8f87a2a9849c7ad1af4e316b47adad2cc1a
        sha512: cb7254cf1b5252d1d10c90d511f988ffd2058fcdc6f6099c9ddae4d1b0e697868c60760b2f07f85c19559e9796529e25e5c66369777b2db0aa7963c6c052f63d
        uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/1/artifacts/kubernetes/v1.19.6/bin/linux/arm64/kubeadm
      description: kubeadm binary for linux/arm64
      name: bin/linux/arm64/kubeadm
      os: linux
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: 27bf9b7efec8cd6ab75698c1ea0092a27f89ababad9454bdb6495d7960a083fd
        sha512: 903d5385ff9e8c0d884615dc8faab3def9ee0cf21863725a5a6b6e8a7b672acf3d106d6ab056c167127fef70791fbdd0cad116143dde3e049018c757c0936f48
        uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/1/artifacts/kubernetes/v1.19.6/bin/linux/amd64/kube-apiserver
      description: kube-apiserver binary for linux/amd64
      name: bin/linux/amd64/kube-apiserver
      os: linux
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: e63098726ba10f63e58f0047f3e06b05857d622ec52d6109fd512e6a8e391306
        sha512: 4d252f8da2b958dd0dbe656a1df47fb3fbeebb4af5489ea943f248afa8ba56b5319a1f72225007cfabd542d93833cd2a042912cc6f71f27fe5052fab0774d35b
        uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/1/artifacts/kubernetes/v1.19.6/bin/linux/amd64/kube-controller-manager
      description: kube-controller-manager binary for linux/amd64
      name: bin/linux/amd64/kube-controller-manager
      os: linux
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: cd1142e350e3348d98987f97c99e4eb75034a389952f214d65d9450204275fe5
        sha512: 68bfbc20e18b8ebb53641ea1b9ec70a883a215b21519cab55eee4bf12cca63c9f0f61a12546a57809bf97aba44c156a5ce3ce9342a1584c73454f95e8d7b75fe
        uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/1/artifacts/kubernetes/v1.19.6/bin/linux/amd64/kube-proxy
      description: kube-proxy binary for linux/amd64
      name: bin/linux/amd64/kube-proxy
      os: linux
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: dc56d981743b30f1b60d962b5dcff1a495e334a44b4b8de493bd1c3a85c9f53b
        sha512: 9d82bca33e6ffa19242e786830dcd9fad1973478a342afeace155388f96d9e20e3035d3cf28ee9217d00d6016d131dad587fcf419f6eca9f683602825ab73ce2
        uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/1/artifacts/kubernetes/v1.19.6/bin/linux/amd64/kube-scheduler
      description: kube-scheduler binary for linux/amd64
      name: bin/linux/amd64/kube-scheduler
      os: linux
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: 4e2c1b438d407b3d4e595d8f01bff838ad1b304e810598fb48ad1ff9dc9b75fe
        sha512: bafaab0616ad55678cc8e85b86f5e7787a72c2836eeafab0b6bb52dabca5141aae7877ec5533c3ff1faac3d4d42efcfb03cfa147b91a9e0de92b365c3d3d0b9c
        uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/1/artifacts/kubernetes/v1.19.6/bin/linux/amd64/kubectl
      description: kubectl binary for linux/amd64
      name: bin/linux/amd64/kubectl
      os: linux
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: 5deeede2c1c8bf8ca46f59effcabbd979a2c651f24ea50c694c1b89f88c51367
        sha512: 3db8d3113df1eb07fcbee2046d613d2f70cd2e3cd9c1c3e7c15f9586cd5301c3d2db7fc8b1379a5b97899dadcc034bedeed30d914d2279b483af7c9360e9697c
        uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/1/artifacts/kubernetes/v1.19.6/bin/linux/amd64/kubelet
      description: kubelet binary for linux/amd64
      name: bin/linux/amd64/kubelet
      os: linux
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: 881793d6c4d9f1dcc14105dcc75436226f8ae38a3becbca30c586d0e28a22a8f
        sha512: c5bb1840bf2686ab7dc95a22784b71d75d784b215532b33bf29d792ee5e3b2fd5d4dab425fb520f8dc4667e7e022bcd865c843ee123a499740836dad5cb7fe69
        uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/1/artifacts/kubernetes/v1.19.6/bin/linux/amd64/kubeadm
      description: kubeadm binary for linux/amd64
      name: bin/linux/amd64/kubeadm
      os: linux
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: a054c8f2ca2d5c052ff73886f5343f3e4625cbd0b3200e0c3a8dfdb1b283067b
        sha512: 816a04f3f198a03eefd8161b074f251b6a45137c91fe071e4424c502d4e6995083634b2e085bef60771fa0a8775cf7cac5ad727b42d379785c50683c340bb2cf
        uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/1/artifacts/kubernetes/v1.19.6/bin/windows/amd64/kube-proxy.exe
      description: kube-proxy.exe binary for windows/amd64
      name: bin/windows/amd64/kube-proxy.exe
      os: windows
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: fb080b75d21f600ab1e949cae0a1c0225cc1a10a6d47b2db8003a481d94e2d5f
        sha512: cf04f8ce4e708b4abc23584712ef8e7c8645d8051a2169c89d6cb2059fc9168ec42430f48de0df825aeb43450c9fbe42ac4a24ecb1b556cc8afe84504e038b58
        uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/1/artifacts/kubernetes/v1.19.6/bin/windows/amd64/kubeadm.exe
      description: kubeadm.exe binary for windows/amd64
      name: bin/windows/amd64/kubeadm.exe
      os: windows
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: f8853aca13797bd33dc2335dc5c7c600fb9287a9f29a90e0088eca19c7cfa7aa
        sha512: 73ec6e3497a491681418c5d36a0efee97e92d7536ab8f9c91648044421d79a3f411d17ce8613f9267b40cecffd365ecab9702aff578fc56dbb3d1c48f9885c32
        uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/1/artifacts/kubernetes/v1.19.6/bin/windows/amd64/kubectl.exe
      description: kubectl.exe binary for windows/amd64
      name: bin/windows/amd64/kubectl.exe
      os: windows
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: f9e502429df49298da7909f51634c2ec62070689dd26c4c969a58eb2ef8df280
        sha512: 4f0a5f665bc7ef7a0d97d2e3229bfb1a3b3e30ea2367b2bd9fd753cdf05a9ee5505b4d44bbefe11c32e6ec4564388410f56a9b642378bb6c2758eea661c95a64
        uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/1/artifacts/kubernetes/v1.19.6/bin/windows/amd64/kubelet.exe
      description: kubelet.exe binary for windows/amd64
      name: bin/windows/amd64/kubelet.exe
      os: windows
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: ad9d9c3f809e2688cacac827423f2885c3a5ba45b3859be0d268995ff15126e8
        sha512: 42f2a8a4193887aae0b31376d85f9d0c01c66030c4707f7cdef26db68ba5cfa743cb3d7683cf413708dae96d38e8e7aa0bf4d13c692da736cfa2f6b749143608
        uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/1/artifacts/kubernetes/v1.19.6/bin/darwin/amd64/kubectl
      description: kubectl binary for darwin/amd64
      name: bin/darwin/amd64/kubectl
      os: darwin
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: 840954b88a2c7638dfedbea507e668eb0137f982bb4fd1e20f06b0a61d3648d5
        sha512: b4016648b62eb949ccc328a7c889c648afb0d76531ab4ea359fa2b0b1c3cf2d306f393792264dcfe474d18f2c581323a80c2a26baeb36ad9fcab98bc3179e7cd
        uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/1/artifacts/kubernetes/v1.19.6/bin/linux/amd64/kube-apiserver.tar
      description: kube-apiserver linux/amd64 OCI image tar
      name: bin/linux/amd64/kube-apiserver.tar
      os: linux
      type: Archive
    - arch:
      - arm64
      archive:
        sha256: 6fb5af8fda307f3f38021b05e929115860e28d9f6084e2e080753883aca57424
        sha512: f2a2b3965d73743a3a39dde3efb28a1c3e786c39d9e2d0a8fb9da12e78d027fcc074477517e962c9816697e141d4faf609e2031bd8a99511076bf39122cedfcf
        uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/1/artifacts/kubernetes/v1.19.6/bin/linux/arm64/kube-apiserver.tar
      description: kube-apiserver linux/arm64 OCI image tar
      name: bin/linux/arm64/kube-apiserver.tar
      os: linux
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: 2175f46c63181514cd7f8c84d84342423c2fe3be165801446590f4fa96991cd9
        sha512: 5ee5c077ab0abef058c01e605f4122b0f67ad1fa27c4905d43a93b759dc7c04b0b3093be79a05c71d41b339894052674bd0aa0390746bf925cd308bc302ba60d
        uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/1/artifacts/kubernetes/v1.19.6/bin/linux/amd64/kube-controller-manager.tar
      description: kube-controller-manager linux/amd64 OCI image tar
      name: bin/linux/amd64/kube-controller-manager.tar
      os: linux
      type: Archive
    - arch:
      - arm64
      archive:
        sha256: c004a16ba827d17804619eea90b6fcbf2ec954c0eecad93065f7e72eace3a9f2
        sha512: 7f4251c4b687f52eebb1ce8b4187f1f3fe540923034729331589798bf6645c21194a41d67a0b717989254f835c041eb412b83bfb16136cdb4b04d3ddcb621979
        uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/1/artifacts/kubernetes/v1.19.6/bin/linux/arm64/kube-controller-manager.tar
      description: kube-controller-manager linux/arm64 OCI image tar
      name: bin/linux/arm64/kube-controller-manager.tar
      os: linux
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: a3a1f50abab2bc797b3632537dfe3842e6cbeb646eb366144175805a2f742122
        sha512: d56a8df6f2805a6606de694bd53fcd0f093997a33fe7d4e6e0ed577552ea814e9a0a137b23b43e746db923da3676f1414266d52b070f167b03ab39836fb3f7b1
        uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/1/artifacts/kubernetes/v1.19.6/bin/linux/amd64/kube-scheduler.tar
      description: kube-scheduler linux/amd64 OCI image tar
      name: bin/linux/amd64/kube-scheduler.tar
      os: linux
      type: Archive
    - arch:
      - arm64
      archive:
        sha256: 5ce0bf6c19f0e7f5d0b4318380c14322f974a6d47e1661cef482d2645a18ea54
        sha512: f6eaf9ece9b0c38781e67b96dc22a11a15666419de8c2eb8de785da9c7c488d73bd0f72af3266136864783de0228b29228f8608a4dbd03a9a1cff9bab2b39e5f
        uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/1/artifacts/kubernetes/v1.19.6/bin/linux/arm64/kube-scheduler.tar
      description: kube-scheduler linux/arm64 OCI image tar
      name: bin/linux/arm64/kube-scheduler.tar
      os: linux
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: 5fd4a4161260372e5463a11f8843e194e31823c881f383b85f4c04566bf72591
        sha512: 17f6e3038d746fd9091fedbb9e05c544d74a2eba340c58026006827ca00b96bca6aa05b6f29308000cf8bb5caba3b9031f15f4d498fc6ae415678618dcff8e25
        uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/1/artifacts/kubernetes/v1.19.6/bin/linux/amd64/kube-proxy.tar
      description: kube-proxy linux/amd64 OCI image tar
      name: bin/linux/amd64/kube-proxy.tar
      os: linux
      type: Archive
    - arch:
      - arm64
      archive:
        sha256: 6fe4221156d98def515068e21fb65464dd716c3193de4aba5a0000c6b06556ad
        sha512: 9b1f6eedde39314606a2ccc5f51fd16606356d3f0db36a434e53f71e063d58edf8256288c02d7e1f227f6f123446bf98723be82810b848be8aba54a934366f7c
        uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/1/artifacts/kubernetes/v1.19.6/bin/linux/arm64/kube-proxy.tar
      description: kube-proxy linux/arm64 OCI image tar
      name: bin/linux/arm64/kube-proxy.tar
      os: linux
      type: Archive
    - archive:
        sha256: 9b3db837d8415ec4924070fc46baa5edfe895c984fb2d0c9029237ad16dd2232
        sha512: 963402cff5dcab80932332b45e5180f4762ce068fec84ac4529ce730204195288d772dae58ff391d2dd4df0c878e45dc2bff9d9b08e302c07c10395db2f0d4f6
        uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/1/artifacts/kubernetes/v1.19.6/kubernetes-src.tar.gz
      description: Kubernetes source tarball
      name: kubernetes-src.tar.gz
      type: Archive
    gitCommit: fbf646b339dc52336b55d8ec85c181981b86331a
    gitTag: v1.19.6
    name: kubernetes
  - assets:
    - arch:
      - amd64
      archive:
        sha256: 0fd0484aeb75e3e771222a2b7b904f032ada960de53d3e621ba3d37273619784
        sha512: 43053da2aa9b29264bf46cb65f803e9490507697e287dc51bc64d9af3553c9223dde8d07c0b0dcd9a178ca90c3c036bea3be59ec3f3559fa9cde0ccd5e2cb51e
        uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/1/artifacts/aws-iam-authenticator/v0.5.2/aws-iam-authenticator-darwin-amd64-v0.5.2.tar.gz
      description: aws-iam-authenticator tarball for darwin/amd64
      name: aws-iam-authenticator-darwin-amd64-v0.5.2.tar.gz
      os: darwin
      type: Archive
    - arch:
      - arm64
      archive:
        sha256: 0df23565b90ef05eb923d11bc77067f6a9f0524a8a06ed24624233aa0d54cac1
        sha512: 4f589e5e639561b0ea5bbd9787f9d5d5e9762eced4c4927bca81eb315cf5ed0f9efd3e8855a8bc54dfff09e544315d903f29efe8c84d3ef4234d87e6ff5e134e
        uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/1/artifacts/aws-iam-authenticator/v0.5.2/aws-iam-authenticator-linux-arm64-v0.5.2.tar.gz
      description: aws-iam-authenticator tarball for linux/arm64
      name: aws-iam-authenticator-linux-arm64-v0.5.2.tar.gz
      os: linux
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: 3f0c4506616a6bc4fb05ca4e0dd1f3640fec38341252737023b258594dda1539
        sha512: 420e9bc9f95e321034f5d360af8b9ae7141681977b5e4bd12cd5e8e97fa714e37802880261372ba5502e125e19d53553a4eefad6d3d6c44638136187e677b401
        uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/1/artifacts/aws-iam-authenticator/v0.5.2/aws-iam-authenticator-linux-amd64-v0.5.2.tar.gz
      description: aws-iam-authenticator tarball for linux/amd64
      name: aws-iam-authenticator-linux-amd64-v0.5.2.tar.gz
      os: linux
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: 032d8549195210851d4ccdfd19dfc805878f8ca2c9f8a6ce841d158b58cfaa47
        sha512: 100253c0dea3164b234f3f252f1b4958d079740ffe54d658ab9de838b924f7bb9c82a5b8fabcfe89527750b98c84e36b6cee4887eb77bb2ae4335720b1c59466
        uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/1/artifacts/aws-iam-authenticator/v0.5.2/aws-iam-authenticator-windows-amd64-v0.5.2.tar.gz
      description: aws-iam-authenticator tarball for windows/amd64
      name: aws-iam-authenticator-windows-amd64-v0.5.2.tar.gz
      os: windows
      type: Archive
    - arch:
      - amd64
      - arm64
      description: aws-iam-authenticator container image
      image:
        uri: /kubernetes-sigs/aws-iam-authenticator:v0.5.2-eks-1-19-1
      name: aws-iam-authenticator-image
      os: linux
      type: Image
    gitTag: v0.5.2
    name: aws-iam-authenticator
  - assets:
    - arch:
      - amd64
      - arm64
      description: livenessprobe container image
      image:
        uri: /kubernetes-csi/livenessprobe:v2.1.0-eks-1-19-1
      name: livenessprobe-image
      os: linux
      type: Image
    gitTag: v2.1.0
    name: livenessprobe
  - assets:
    - arch:
      - amd64
      - arm64
      description: node-driver-registrar container image
      image:
        uri: /kubernetes-csi/node-driver-registrar:v2.0.1-eks-1-19-1
      name: node-driver-registrar-image
      os: linux
      type: Image
    gitTag: v2.0.1
    name: node-driver-registrar
  - assets:
    - arch:
      - arm64
      archive:
        sha256: e7d592a173e393b3fc7484a87a2c1ad8c0740d2e8f2875fbaceb2bc938016da1
        sha512: 71cfc444a8b2ba45cfe3a15f01bb5a578c866ce32edd9e82fcdbfe0b335cdabf47e37dde9af5172e635802aa6703cf261c435a1e134b8dce50d552a39e8ec7ba
        uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/1/artifacts/plugins/v0.8.7/cni-plugins-linux-arm64-v0.8.7.tar.gz
      description: cni-plugins tarball for linux/arm64
      name: cni-plugins-linux-arm64-v0.8.7.tar.gz
      os: linux
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: 04b72745963f66e1a61a4f6263eeb90f776b395d7f8c558fc7dfdbb80b0f43d7
        sha512: 18ecb752b5e49f050c072dc7cf337d6463591a0f2c6b1e76a33d89736c76124dd48d4fd85881682d2392703c62ad34d8ffcba87b13d0c720c51d5c12bdfd868d
        uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/1/artifacts/plugins/v0.8.7/cni-plugins-linux-amd64-v0.8.7.tar.gz
      description: cni-plugins tarball for linux/amd64
      name: cni-plugins-linux-amd64-v0.8.7.tar.gz
      os: linux
      type: Archive
    gitTag: v0.8.7
    name: cni-plugins
  - assets:
    - arch:
      - arm64
      archive:
        sha256: 111a292aed4d94687411f8017158b8bfc355ea6e7fe4ecac092bf173c3bf1a0a
        sha512: 5d29f38f265db12bb9d327a0a455eb3902f1ae40509d89c2fa54776309762a396f69aa4ec36b84087c328792280290c83d1b430563c05c5eb95d3188e2dada28
        uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/1/artifacts/etcd/v3.4.14/etcd-linux-arm64-v3.4.14.tar.gz
      description: etcd tarball for linux/arm64
      name: etcd-linux-arm64-v3.4.14.tar.gz
      os: linux
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: 7d6a631d35b3e30534a11aa85c83167bd9db574b8ace85a78fa3ef74507ad6f9
        sha512: 8f5299c912b597317900eb825fb2f62363e2835b790669318491fc0a3f82506ab526aa3c67ae6e02fec88ab745afd69254852531c473cd029dbdc594655839fd
        uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/1/artifacts/etcd/v3.4.14/etcd-linux-amd64-v3.4.14.tar.gz
      description: etcd tarball for linux/amd64
      name: etcd-linux-amd64-v3.4.14.tar.gz
      os: linux
      type: Archive
    - arch:
      - amd64
      - arm64
      description: etcd container image
      image:
        uri: /etcd-io/etcd:v3.4.14-eks-1-19-1
      name: etcd-image
      os: linux
      type: Image
    gitTag: v3.4.14
    name: etcd
  - assets:
    - arch:
      - amd64
      - arm64
      description: external-attacher container image
      image:
        uri: /kubernetes-csi/external-attacher:v3.0.1-eks-1-19-1
      name: external-attacher-image
      os: linux
      type: Image
    gitTag: v3.0.1
    name: external-attacher
  - assets:
    - arch:
      - amd64
      - arm64
      description: external-provisioner container image
      image:
        uri: /kubernetes-csi/external-provisioner:v2.0.3-eks-1-19-1
      name: external-provisioner-image
      os: linux
      type: Image
    gitTag: v2.0.3
    name: external-provisioner
  - assets:
    - arch:
      - amd64
      - arm64
      description: external-resizer container image
      image:
        uri: /kubernetes-csi/external-resizer:v1.0.1-eks-1-19-1
      name: external-resizer-image
      os: linux
      type: Image
    gitTag: v1.0.1
    name: external-resizer
  - assets:
    - arch:
      - amd64
      - arm64
      description: csi-snapshotter container image
      image:
        uri: /kubernetes-csi/external-snapshotter/csi-snapshotter:v3.0.2-eks-1-19-1
      name: csi-snapshotter-image
      os: linux
      type: Image
    - arch:
      - amd64
      - arm64
      description: snapshot-controller container image
      image:
        uri: /kubernetes-csi/external-snapshotter/snapshot-controller:v3.0.2-eks-1-19-1
      name: snapshot-controller-image
      os: linux
      type: Image
    - arch:
      - amd64
      - arm64
      description: snapshot-validation-webhook container image
      image:
        uri: /kubernetes-csi/external-snapshotter/snapshot-validation-webhook:v3.0.2-eks-1-19-1
      name: snapshot-validation-webhook-image
      os: linux
      type: Image
    gitTag: v3.0.2
    name: external-snapshotter
  - assets:
    - arch:
      - amd64
      - arm64
      description: metrics-server container image
      image:
        uri: /kubernetes-sigs/metrics-server:v0.4.0-eks-1-19-1
      name: metrics-server-image
      os: linux
      type: Image
    gitTag: v0.4.0
    name: metrics-server
  - assets:
    - arch:
      - amd64
      - arm64
      description: coredns container image
      image:
        uri: /coredns/coredns:v1.8.0-eks-1-19-1
      name: coredns-image
      os: linux
      type: Image
    gitTag: v1.8.0
    name: coredns
  date: "2021-02-18T14:51:30Z"

```
