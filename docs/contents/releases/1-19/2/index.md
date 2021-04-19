# EKS-D v1-19-eks-2 Release

Highlights of the Kubernetes 1.19 release include Ingress API and Pod Topology
Spread reaching stable status, EndpointSlices being enabled by default, and
immutable Secrets and ConfigMaps. A [change log](CHANGELOG-v1-19-eks-2.md) is available
describing the patches and versions included in this release.

The [EKS-D v1-19-eks-2](https://distro.eks.amazonaws.com/kubernetes-1-19/kubernetes-1-19-eks-2.yaml)
release manifest defines the release used in EKS-D.

```yaml
---
apiVersion: distro.eks.amazonaws.com/v1alpha1
kind: Release
metadata:
  creationTimestamp: null
  name: kubernetes-1-19-eks-2
spec:
  channel: 1-19
  number: 2
status:
  components:
    - assets:
        - arch:
            - arm64
          archive:
            sha256: 53649e45b66e4e42580de96ff182a98918282981572e1bf177ff57239aa4b09f
            sha512: 9c752b25cc351d2e83a56c05e92774b9d3d1dc6ac9f1f3235699a28eafd76b2e0b8a0e7ca6e298813794389796d77ddb13526da1cc24f859818a77428b97ded0
            uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/2/artifacts/etcd/v3.4.14/etcd-linux-arm64-v3.4.14.tar.gz
          description: etcd tarball for linux/arm64
          name: etcd-linux-arm64-v3.4.14.tar.gz
          os: linux
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: ad91e4cdcc0402761048e5a51f45fc03feaa6140e486cc98381d3baf33cdb7e8
            sha512: 0d06b01005e4c5940ea9bc429f55b389f74e1728d0104b437a1b0da29ccf27a89aec1af1a85ab136a0bb18e2e1431978dc443bb7e669e3c0707da89535b52fa1
            uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/2/artifacts/etcd/v3.4.14/etcd-linux-amd64-v3.4.14.tar.gz
          description: etcd tarball for linux/amd64
          name: etcd-linux-amd64-v3.4.14.tar.gz
          os: linux
          type: Archive
        - arch:
            - amd64
            - arm64
          description: etcd container image
          image:
            uri: public.ecr.aws/eks-distro/etcd-io/etcd:v3.4.14-eks-1-19-2
          name: etcd-image
          os: linux
          type: Image
      gitTag: v3.4.14
      name: etcd
    - assets:
        - arch:
            - amd64
            - arm64
          description: coredns container image
          image:
            uri: public.ecr.aws/eks-distro/coredns/coredns:v1.8.0-eks-1-19-2
          name: coredns-image
          os: linux
          type: Image
      gitTag: v1.8.0
      name: coredns
    - assets:
        - arch:
            - arm64
          archive:
            sha256: df3c62d9027285af9da51c3f966034b4d00ac5a07c40aca4e5fb246a51c27de1
            sha512: 95bc10e41894600c78b673acc8b95a4e9a56bdc52979b806e40042bb874b4b087d1a4dd89c12b05c5e21ade2e0b6d6b43dbb3b8b35af11ec44eb50b0ac4e6d4d
            uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/2/artifacts/aws-iam-authenticator/v0.5.2/aws-iam-authenticator-linux-arm64-v0.5.2.tar.gz
          description: aws-iam-authenticator tarball for linux/arm64
          name: aws-iam-authenticator-linux-arm64-v0.5.2.tar.gz
          os: linux
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: da1181bff3bcf42ee5dc21d31acbc5985d2641b17cd255e05a164099503125f5
            sha512: 64452863c5fd19cf56c1ccda9a8c2d420b312ca6b7d0891551d21b786624c3f78083ea9a464dad872e0d934ea582ee3e46f0d9925b049b031c105ebf57d92592
            uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/2/artifacts/aws-iam-authenticator/v0.5.2/aws-iam-authenticator-linux-amd64-v0.5.2.tar.gz
          description: aws-iam-authenticator tarball for linux/amd64
          name: aws-iam-authenticator-linux-amd64-v0.5.2.tar.gz
          os: linux
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: 7d8ea585da2f8168fc05ad0f977875ac09bac0d99cfaa5f4b775b53d036e9d68
            sha512: 8fcf16e810b3cdff9acd5612cb0824a04446600667efbaab5f005528c6c8839e3834b778a5e28406a6b302b5c3d4d1c88216c8146845614dbe1d6062a0ef4878
            uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/2/artifacts/aws-iam-authenticator/v0.5.2/aws-iam-authenticator-windows-amd64-v0.5.2.tar.gz
          description: aws-iam-authenticator tarball for windows/amd64
          name: aws-iam-authenticator-windows-amd64-v0.5.2.tar.gz
          os: windows
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: 816e066b19b56d2418263a0df0038af3eb9238fa7e18acde424c4a1b6334432c
            sha512: 74af76b10128779196b8e0638ded0042e945ac9f14d05383fc09068a89cede24a19dd3997537df59aa83c1464039facb996f37ccf2f7af4b0ef77666d9e68ae0
            uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/2/artifacts/aws-iam-authenticator/v0.5.2/aws-iam-authenticator-darwin-amd64-v0.5.2.tar.gz
          description: aws-iam-authenticator tarball for darwin/amd64
          name: aws-iam-authenticator-darwin-amd64-v0.5.2.tar.gz
          os: darwin
          type: Archive
        - arch:
            - amd64
            - arm64
          description: aws-iam-authenticator container image
          image:
            uri: public.ecr.aws/eks-distro/kubernetes-sigs/aws-iam-authenticator:v0.5.2-eks-1-19-2
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
            uri: public.ecr.aws/eks-distro/kubernetes-csi/livenessprobe:v2.2.0-eks-1-19-2
          name: livenessprobe-image
          os: linux
          type: Image
      gitTag: v2.2.0
      name: livenessprobe
    - assets:
        - arch:
            - amd64
            - arm64
          description: csi-snapshotter container image
          image:
            uri: public.ecr.aws/eks-distro/kubernetes-csi/external-snapshotter/csi-snapshotter:v3.0.3-eks-1-19-2
          name: csi-snapshotter-image
          os: linux
          type: Image
        - arch:
            - amd64
            - arm64
          description: snapshot-controller container image
          image:
            uri: public.ecr.aws/eks-distro/kubernetes-csi/external-snapshotter/snapshot-controller:v3.0.3-eks-1-19-2
          name: snapshot-controller-image
          os: linux
          type: Image
        - arch:
            - amd64
            - arm64
          description: snapshot-validation-webhook container image
          image:
            uri: public.ecr.aws/eks-distro/kubernetes-csi/external-snapshotter/snapshot-validation-webhook:v3.0.3-eks-1-19-2
          name: snapshot-validation-webhook-image
          os: linux
          type: Image
      gitTag: v3.0.3
      name: external-snapshotter
    - assets:
        - arch:
            - amd64
            - arm64
          description: metrics-server container image
          image:
            uri: public.ecr.aws/eks-distro/kubernetes-sigs/metrics-server:v0.4.0-eks-1-19-2
          name: metrics-server-image
          os: linux
          type: Image
      gitTag: v0.4.0
      name: metrics-server
    - assets:
        - arch:
            - arm64
          archive:
            sha256: aeab79389da6cb34e914093db6d087ef4c0bb9d9668c6ca401d7c246653dea9b
            sha512: e4df8a98c50e2c5504c9bb0a18e704417d26b4ad200645525441abe563d1f680bf883b7f79afe6ead097b26c31a061c92dde5755f02cf0b8fe9d7de9b47549aa
            uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/2/artifacts/plugins/v0.8.7/cni-plugins-linux-arm64-v0.8.7.tar.gz
          description: cni-plugins tarball for linux/arm64
          name: cni-plugins-linux-arm64-v0.8.7.tar.gz
          os: linux
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: 9573e373894f5e85b943a407a36c60a5b42ddaafae82561b1ff3a1accf80ebcc
            sha512: 5e9dda68274ccf5d2516bc86ae38e4cc4ed3e882dd5186f9fb3481caca23584f2c0df07d6e013eab6855564b7c3bfb0449d9873d9d1b3801c0bc1d93672cd708
            uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/2/artifacts/plugins/v0.8.7/cni-plugins-linux-amd64-v0.8.7.tar.gz
          description: cni-plugins tarball for linux/amd64
          name: cni-plugins-linux-amd64-v0.8.7.tar.gz
          os: linux
          type: Archive
      gitTag: v0.8.7
      name: cni-plugins
    - assets:
        - arch:
            - amd64
          archive:
            sha256: 3bad82feb42dc4d98862d3717d0cb1fd54127cd644372a527f3f62fd62853a4f
            sha512: e375957efc214d08767200bb1cb4cc72088b332c8f2c00ca709d20e946e9b4557295c100995d4d6fc5a934d5f0e663cb86e31ea0db1a3874f409a2aeeccff915
            uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/2/artifacts/kubernetes/v1.19.6/kubernetes-client-darwin-amd64.tar.gz
          description: Kubernetes client tarball for darwin/amd64
          name: kubernetes-client-darwin-amd64.tar.gz
          os: darwin
          type: Archive
        - arch:
            - arm64
          archive:
            sha256: 50b43829906db0fdd0794ec6b7d7ab0c6fecde65bf700c208b01248fd5a17f37
            sha512: b0e7dc986f930a9c0faf98d51eff155832584c12c117f3ef11598bcd7d28331684c5bf30f4d22d054a80b08538468ab48698669ccab9ea7d9780925a87eb626d
            uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/2/artifacts/kubernetes/v1.19.6/kubernetes-client-linux-arm64.tar.gz
          description: Kubernetes client tarball for linux/arm64
          name: kubernetes-client-linux-arm64.tar.gz
          os: linux
          type: Archive
        - arch:
            - arm64
          archive:
            sha256: a7c059ff5fc858262788802ccf07fec087214ac91bde90bb2483ea6cf6e0722e
            sha512: 43b5861417b5716b79df228617d992cdb9529646336456b3ed42390edb58cef82bae391e9d0bcd968f5b7b188851f28f6f41bdf699cad23617a639fe9344c2cc
            uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/2/artifacts/kubernetes/v1.19.6/kubernetes-server-linux-arm64.tar.gz
          description: Kubernetes server tarball for linux/arm64
          name: kubernetes-server-linux-arm64.tar.gz
          os: linux
          type: Archive
        - arch:
            - arm64
          archive:
            sha256: cffb71c1df99b8d7187c5af80dadcc7a84653cf575d86b2aa7d99f999a223695
            sha512: 539914db80b20ff71d310cf202755ce07dbf778767cbcf7e764a282a6bb7753c8b11242d3a1e53ff9bbe64fa96d99d95bb71642f5afb8e0d845dd69a53715170
            uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/2/artifacts/kubernetes/v1.19.6/kubernetes-node-linux-arm64.tar.gz
          description: Kubernetes node tarball for linux/arm64
          name: kubernetes-node-linux-arm64.tar.gz
          os: linux
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: fc9bba332758288c6e901f936492647449a86d0cd0127fd3e171e545ef4ca746
            sha512: 118917b248d40b76bbd9bc50b5319c6c76d3b3ad1338d33f4c19156757dd2777f06eeabd31b1d086f45b98b92cb2ee810dad9ec029e9063a6015a2d67fc8dcf8
            uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/2/artifacts/kubernetes/v1.19.6/kubernetes-client-linux-amd64.tar.gz
          description: Kubernetes client tarball for linux/amd64
          name: kubernetes-client-linux-amd64.tar.gz
          os: linux
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: a195d798e8de057d38886efa5557ad6953b62099ce49f58733aa908d83359de1
            sha512: 79ac05ddd863c5ee37c9828b66f000dce1670eee2f41d0ba31abac9f300e4762b0afb9312a42a9de12539037ee829c659f24ad6dc24826a3386039a658bb1673
            uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/2/artifacts/kubernetes/v1.19.6/kubernetes-server-linux-amd64.tar.gz
          description: Kubernetes server tarball for linux/amd64
          name: kubernetes-server-linux-amd64.tar.gz
          os: linux
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: 91ace27b28c38087cd6e9fe33a7817a5bd96dc316b17b2a77ef9fa5853f5ea71
            sha512: 47ad2dcd89b3230039d708713b588f1b04c7ac30d01120577d69497d8a1f7f71fbd154ed4cd0065fa4b8c2feb8856b6f07342db859c09670d878e634263e2567
            uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/2/artifacts/kubernetes/v1.19.6/kubernetes-node-linux-amd64.tar.gz
          description: Kubernetes node tarball for linux/amd64
          name: kubernetes-node-linux-amd64.tar.gz
          os: linux
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: 74f231b7af243cc53d252af23df049e17eb5e932b1eda9e3710b5b5ac2d00475
            sha512: de2514235d6ba36a87e18475e52272af21836d73809f2094bef00ee3fb0d6eeb105ea4a6d14815df6ab887e96e790904d982c3c94da825f60a3b1ed4937e7ad8
            uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/2/artifacts/kubernetes/v1.19.6/kubernetes-client-windows-amd64.tar.gz
          description: Kubernetes client tarball for windows/amd64
          name: kubernetes-client-windows-amd64.tar.gz
          os: windows
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: b34adfc50d5182a9d17f8e162affecefd8dd2529b32370b03416bc34069842f0
            sha512: afe34f01f7bd5f3cbfb358289bf98b61f6f61d5fd4d5de699722762beed03b7c81bfc8c1a7d3830785af2ca6b8431f6e338c5aee7a7331ba2cc3e84e43d16daa
            uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/2/artifacts/kubernetes/v1.19.6/kubernetes-node-windows-amd64.tar.gz
          description: Kubernetes node tarball for windows/amd64
          name: kubernetes-node-windows-amd64.tar.gz
          os: windows
          type: Archive
        - arch:
            - amd64
            - arm64
          description: kube-apiserver container image
          image:
            uri: public.ecr.aws/eks-distro/kubernetes/kube-apiserver:v1.19.6-eks-1-18-2
          name: kube-apiserver-image
          os: linux
          type: Image
        - arch:
            - amd64
            - arm64
          description: kube-controller-manager container image
          image:
            uri: public.ecr.aws/eks-distro/kubernetes/kube-controller-manager:v1.19.6-eks-1-18-2
          name: kube-controller-manager-image
          os: linux
          type: Image
        - arch:
            - amd64
            - arm64
          description: kube-scheduler container image
          image:
            uri: public.ecr.aws/eks-distro/kubernetes/kube-scheduler:v1.19.6-eks-1-18-2
          name: kube-scheduler-image
          os: linux
          type: Image
        - arch:
            - amd64
            - arm64
          description: kube-proxy container image
          image:
            uri: public.ecr.aws/eks-distro/kubernetes/kube-proxy:v1.19.6-eks-1-18-2
          name: kube-proxy-image
          os: linux
          type: Image
        - arch:
            - amd64
            - arm64
          description: pause container image
          image:
            uri: public.ecr.aws/eks-distro/kubernetes/pause:v1.19.6-eks-1-18-2
          name: pause-image
          os: linux
          type: Image
        - arch:
            - amd64
          archive:
            sha256: 2683c8a3bc0e158a5f1679fd352eb42b5fc28c2c66af90072facdf3130402cde
            sha512: 73e5bc18b6882a07c9bf73646c35609ee6678ae49bf7faee1c3792654bc85ebcb9a8423a49540ad684f545954c114cfc2b32fc0d142f96e6a99d33f9bf220ef7
            uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/2/artifacts/kubernetes/v1.19.6/bin/darwin/amd64/kubectl
          description: kubectl binary for darwin/amd64
          name: bin/darwin/amd64/kubectl
          os: darwin
          type: Archive
        - arch:
            - arm64
          archive:
            sha256: 23729dec605d49b08da834c220bec179998d3b25956eceb420f8ac7c59963070
            sha512: dd79740e25f99168f13951c37fb8441513d11b1a18235844f2b6969e7a87765e8db1f3e21915e972cf79aeb13e70abbec4d2b88b980dd8d3c6851621aad944f2
            uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/2/artifacts/kubernetes/v1.19.6/bin/linux/arm64/kube-apiserver
          description: kube-apiserver binary for linux/arm64
          name: bin/linux/arm64/kube-apiserver
          os: linux
          type: Archive
        - arch:
            - arm64
          archive:
            sha256: 85d0e23253b9f0cc7a896468cff72ef6b03029ae6326213c1cb78592c29a55fe
            sha512: 4fe86bfbfbb0fdf475475e28a87b09a4ca50a3ba223967e4fd6546a120736f697589f32c3359ec80bd749c9765dd5f34fa109c226bc3ac31c1391cdecb6eaf1d
            uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/2/artifacts/kubernetes/v1.19.6/bin/linux/arm64/kube-controller-manager
          description: kube-controller-manager binary for linux/arm64
          name: bin/linux/arm64/kube-controller-manager
          os: linux
          type: Archive
        - arch:
            - arm64
          archive:
            sha256: 9b7607f92cf91db21bb8761aa28bce3b2744d403ee4985fe8352c520b41664b9
            sha512: 04e3d17378ec6fd5939e4659e7a139e46813372d1e2e4a776503bd1539aaf3ac29e3dc54aa5084c7eb6e89be4ba223eeae71650392ab3eb2d6ac1761b6de611f
            uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/2/artifacts/kubernetes/v1.19.6/bin/linux/arm64/kube-proxy
          description: kube-proxy binary for linux/arm64
          name: bin/linux/arm64/kube-proxy
          os: linux
          type: Archive
        - arch:
            - arm64
          archive:
            sha256: e1067ec327171b302268f5cca9b1b21477ecfb52f254941cfd6d0f1c816982a6
            sha512: bf18604274f221fbea8b730d2332e2083b5e296e2da9d089ba2511a5ccb312d956cd989e1a1d7e16d3e24b528403a4f206f8a615e69ea41f391b82bb0788b98e
            uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/2/artifacts/kubernetes/v1.19.6/bin/linux/arm64/kube-scheduler
          description: kube-scheduler binary for linux/arm64
          name: bin/linux/arm64/kube-scheduler
          os: linux
          type: Archive
        - arch:
            - arm64
          archive:
            sha256: d911c5702b5527321c0d6810435536c0d5d692a658fcb76021e02a1c54ae77d2
            sha512: c99c42e377cb6ada7ff8c456dfa098ef5d58a58dc15d9d78f07b2b91ad7ec3581ce37ff829e81c2d97ece47efbe5b58a542fd7c7d4b1cdee5075186c474e984f
            uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/2/artifacts/kubernetes/v1.19.6/bin/linux/arm64/kubectl
          description: kubectl binary for linux/arm64
          name: bin/linux/arm64/kubectl
          os: linux
          type: Archive
        - arch:
            - arm64
          archive:
            sha256: 7cfa6d0df9fff4418b2ae976ae4831899884feba4dfd0380d8123040f6ebc8a2
            sha512: 79409d5ea05bf1549030480618e91f199fe44689ea8fecde55a77c91d4b61957a1223c1651f0c46111832f36910c5714b37ac25357e24d259392d95246a6364c
            uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/2/artifacts/kubernetes/v1.19.6/bin/linux/arm64/kubelet
          description: kubelet binary for linux/arm64
          name: bin/linux/arm64/kubelet
          os: linux
          type: Archive
        - arch:
            - arm64
          archive:
            sha256: cfac0e33b0e93a49dc0b9eeb7fdc396d1408b3b8fdbb34e7a5045d8bb3c4c4eb
            sha512: 81490f058c957f9ec6c582c1468b58a66fc0fbce4d5591dc0cab9e65e3539f7c4fabb83004ca580a50ebfa24ce72d10a7b87377594e36dd3e5d87f653fb781f4
            uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/2/artifacts/kubernetes/v1.19.6/bin/linux/arm64/kubeadm
          description: kubeadm binary for linux/arm64
          name: bin/linux/arm64/kubeadm
          os: linux
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: 71f911adc9da17774002ac9ae6f881fb456a6742bd77d6984e1158a69770c516
            sha512: 9bcc049fe4490e3215c5ab27382b24822e0cf0c79c9a52b35843af4c48a0e2b420b2b98644ae93be685a221fb43de88ebfd6d4a23c907cb57ae464ed4af5175c
            uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/2/artifacts/kubernetes/v1.19.6/bin/linux/amd64/kube-apiserver
          description: kube-apiserver binary for linux/amd64
          name: bin/linux/amd64/kube-apiserver
          os: linux
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: 2e76c3a129844f96c8228fda4f9ab55e641539ef726c41e470ef1b6827e59794
            sha512: 18770138b332e990078ccedbc08a1110c51447511dd0e277361fb537f485bb4e38c9901ad4f2bf568d008cda142442a8abe3cdb3df6aa9fb74d42adb14b292cd
            uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/2/artifacts/kubernetes/v1.19.6/bin/linux/amd64/kube-controller-manager
          description: kube-controller-manager binary for linux/amd64
          name: bin/linux/amd64/kube-controller-manager
          os: linux
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: e97ff00678cd7bc9d9652e7260a185fb9bbe96c13ecb19067b88f0d4c172e7ae
            sha512: 3133e03d7f445c21c7fab7b90e44d79a2e76937065102561d4d1cdad66bbe727ef58b2652d09714be1d6a4d865ff1a2c1d27017f1c169ef2050f70a2c2fcdcae
            uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/2/artifacts/kubernetes/v1.19.6/bin/linux/amd64/kube-proxy
          description: kube-proxy binary for linux/amd64
          name: bin/linux/amd64/kube-proxy
          os: linux
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: d9ff5d18c16c5251de00d3c9870072314d4ca2c58e96faa0b2e93ff49c45a448
            sha512: 4f123443805f45cb88faa090cd8bd014d0daa936382d0a892b1e93562d644f00a6664abf0bee4f1edbbbc188aa059436327c1c96e324d50049c3ea2c2da3bd70
            uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/2/artifacts/kubernetes/v1.19.6/bin/linux/amd64/kube-scheduler
          description: kube-scheduler binary for linux/amd64
          name: bin/linux/amd64/kube-scheduler
          os: linux
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: dcb0b6214075f70bd3e9b87f4233eda9e38e7bb3207d316783289a9ee5d2002a
            sha512: 468f059c96cd875aced9cfe49f4f06f9e29edf8358191067739d35d3f074792b47a0951a65b52e3807264a37c4f6f517031f04435ce7cf5b9fc1969de845b143
            uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/2/artifacts/kubernetes/v1.19.6/bin/linux/amd64/kubectl
          description: kubectl binary for linux/amd64
          name: bin/linux/amd64/kubectl
          os: linux
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: c50c543c007a1d85c85fe0ccc5701e3ed3f9c442c45946aa5cc2f6507fd873aa
            sha512: 6eb7c381d24eef4c39896bd8501f6d319a71b4021ec3eabfcfe8250a33301882d57e7378eb2858d935462998089105ca55fd097a090fd54abb5aaa61ab7c2d69
            uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/2/artifacts/kubernetes/v1.19.6/bin/linux/amd64/kubelet
          description: kubelet binary for linux/amd64
          name: bin/linux/amd64/kubelet
          os: linux
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: b430ef4d4beb175ba5aa31303fe18875fbff41eea9e924b9796b26f94e891b3c
            sha512: 10511b172224794a1ed15c17b77ebc90ac902a29448abf5cdeaca18701ca3ab7c65a66108baeab9065936cf1e54f5f53f47c372b65c02f65783efe64e0496f1b
            uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/2/artifacts/kubernetes/v1.19.6/bin/linux/amd64/kubeadm
          description: kubeadm binary for linux/amd64
          name: bin/linux/amd64/kubeadm
          os: linux
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: 65f6b4549cb0b9cdda829c16a09ba9363d4572ec6bf78bc4bd92b849c2339fb5
            sha512: abba3aa0fa44083484d06ba77e7059270b20636e4d9a5c98e982a192e504602b6f6cf81ab7ce5460357a343ec3962203b2233c0626eb2096a1f087bf53942064
            uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/2/artifacts/kubernetes/v1.19.6/bin/windows/amd64/kube-proxy.exe
          description: kube-proxy.exe binary for windows/amd64
          name: bin/windows/amd64/kube-proxy.exe
          os: windows
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: a1e0d7e9e614d9971fa3642e7cc344e7256b407c831fc22b65db245bee4f592f
            sha512: 865e326a4961fcd98be7874692113655beadab4bdaa8915d853d09a846cafb00adfe536d771380fe3b9b4111fd03907e03564bc7b066acf718e7b8ab1f69591d
            uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/2/artifacts/kubernetes/v1.19.6/bin/windows/amd64/kubeadm.exe
          description: kubeadm.exe binary for windows/amd64
          name: bin/windows/amd64/kubeadm.exe
          os: windows
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: a37af8e7bb5cd765581108539ac1cb48bebd39e1d91ae0eae7525101f4659635
            sha512: 28b1555d4bd8067fe789a47789d8b34bddedf5c11d7bfbe291d29231e4a523aa604eae05b1037ec4fae207ffd0fd49deafcc525b8af4dd34ab6d751acd60a917
            uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/2/artifacts/kubernetes/v1.19.6/bin/windows/amd64/kubectl.exe
          description: kubectl.exe binary for windows/amd64
          name: bin/windows/amd64/kubectl.exe
          os: windows
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: f6568d8170615aba39628aa2df1d99b59558d68264da8fdd65b221ff6b9b2150
            sha512: 0395d8e9bd400a0d6c05ca9e0604fc99a43ce931886effa0f52d6d9dd28bad206c82c1c2db8c8be4a473642477b74b4a7a216f38b5ffeb28384220e144ad2455
            uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/2/artifacts/kubernetes/v1.19.6/bin/windows/amd64/kubelet.exe
          description: kubelet.exe binary for windows/amd64
          name: bin/windows/amd64/kubelet.exe
          os: windows
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: a919fa2d185705718896ce1298a54e3db599213ca47113bd9764e847ad93d0a5
            sha512: ed64eb75e56e7e20fe6e527652c16ec3b52f4cf6f62ddae999d9e1a2a8065fd28cdfe1da4930bda13ab2b4a20884f3f0679d1f233fe747c7d03607ea8ca93a38
            uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/2/artifacts/kubernetes/v1.19.6/bin/linux/amd64/kube-apiserver.tar
          description: kube-apiserver linux/amd64 OCI image tar
          name: bin/linux/amd64/kube-apiserver.tar
          os: linux
          type: Archive
        - arch:
            - arm64
          archive:
            sha256: 27e3599d906b3cbb39329b4fc5655ab93c6eb214e7aa2d9efdf42bebbcdcdc8e
            sha512: 2a0d280ac67fb9f2ff439b21fe0896f847f36110666ce148731ff928d2f02f5c06986886e185bfde775554a44696881500f97488a6984d98328b797627241b5c
            uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/2/artifacts/kubernetes/v1.19.6/bin/linux/arm64/kube-apiserver.tar
          description: kube-apiserver linux/arm64 OCI image tar
          name: bin/linux/arm64/kube-apiserver.tar
          os: linux
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: 918a68064fb8a444482d6d7a19c69b77456c7622772d2a090f547fdcd5304811
            sha512: 6d0ddef28f7fe6e6c12b956412f388766c522808a70ec392ec87982d356316b14947d9e7158aa81e67e393f3d31c7cede3f31456b69e194ba800458fc5a36ec6
            uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/2/artifacts/kubernetes/v1.19.6/bin/linux/amd64/kube-controller-manager.tar
          description: kube-controller-manager linux/amd64 OCI image tar
          name: bin/linux/amd64/kube-controller-manager.tar
          os: linux
          type: Archive
        - arch:
            - arm64
          archive:
            sha256: 23afcca04c071cfbb7a41c8dc94b5a94e55915afe8a591f35abb1582f046e398
            sha512: 17825da5f5ab2921f764561059288cccd6672e3ddd5456f187f43d641c11753f2747549e33050643082615ecc94e82613c66fcae9e0c529d66ee60a7b626df34
            uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/2/artifacts/kubernetes/v1.19.6/bin/linux/arm64/kube-controller-manager.tar
          description: kube-controller-manager linux/arm64 OCI image tar
          name: bin/linux/arm64/kube-controller-manager.tar
          os: linux
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: 5f663a6363e122c1244db89f72f2d2eb9c9c3016553fe583ee61690e5e8c5aa3
            sha512: 18ac903c6431074f8ea04669b184b39fef60238f22bf4b5c0bc780abb43a2498b27711148ca7c9459a74b0a347a71030a8dcad06f0f64e17cd06d87efd4ec9fc
            uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/2/artifacts/kubernetes/v1.19.6/bin/linux/amd64/kube-scheduler.tar
          description: kube-scheduler linux/amd64 OCI image tar
          name: bin/linux/amd64/kube-scheduler.tar
          os: linux
          type: Archive
        - arch:
            - arm64
          archive:
            sha256: e22bf7acc6f418570e24cb28dac68b2e00587d7268cfa4269e326cf314ca3130
            sha512: 2ca3b3c4c47b4a6ef544d78df002abf22c5a792c8cec7ee348474bc61bb04475b874a415c1153013401a809aede7f9205a994bb5d6d0b84e421683dca68c3316
            uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/2/artifacts/kubernetes/v1.19.6/bin/linux/arm64/kube-scheduler.tar
          description: kube-scheduler linux/arm64 OCI image tar
          name: bin/linux/arm64/kube-scheduler.tar
          os: linux
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: 47951e883f7324849cf799c64ec2887d86a0b973b798bbec7091f2a8b0915e47
            sha512: d59e2b931551231a264e2b6114d91ae434d0b6e6778b8d5bbaffda51284bf1b5e8f3d7082abbb26fee326963b66c1cc1dc6b7c0ea7d7cc5f37365c5bb7fe589f
            uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/2/artifacts/kubernetes/v1.19.6/bin/linux/amd64/kube-proxy.tar
          description: kube-proxy linux/amd64 OCI image tar
          name: bin/linux/amd64/kube-proxy.tar
          os: linux
          type: Archive
        - arch:
            - arm64
          archive:
            sha256: fc4318f6226b09c8813ec0cb7f045adfeb99ddb8385baf187ec356276ec1a601
            sha512: 822cf32abda05817e62dd605e8c6d2332b879078aa34e6e0d28d855a46f4b581756d62cfe07f727197ea418e6a7c5ce264fd2da2dbc49d8cbca3a3b963d512c8
            uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/2/artifacts/kubernetes/v1.19.6/bin/linux/arm64/kube-proxy.tar
          description: kube-proxy linux/arm64 OCI image tar
          name: bin/linux/arm64/kube-proxy.tar
          os: linux
          type: Archive
        - archive:
            sha256: 05a7e7dc1009be329b2bb321c16421416a6519c2375032469094bf5d392e0ca7
            sha512: 7f8584de8f2f5de9c683ed9877c69d0b1e336da88b583b31881f53babb3c6d8b4b76454887079eea5bfd5fcea29188e0b2495d1b61365d3e9c6ceb7bb995de92
            uri: https://distro.eks.amazonaws.com/kubernetes-1-19/releases/2/artifacts/kubernetes/v1.19.6/kubernetes-src.tar.gz
          description: Kubernetes source tarball
          name: kubernetes-src.tar.gz
          type: Archive
      gitCommit: fbf646b339dc52336b55d8ec85c181981b86331a
      gitTag: v1.19.6
      name: kubernetes
    - assets:
        - arch:
            - amd64
            - arm64
          description: external-attacher container image
          image:
            uri: public.ecr.aws/eks-distro/kubernetes-csi/external-attacher:v3.1.0-eks-1-19-2
          name: external-attacher-image
          os: linux
          type: Image
      gitTag: v3.1.0
      name: external-attacher
    - assets:
        - arch:
            - amd64
            - arm64
          description: external-provisioner container image
          image:
            uri: public.ecr.aws/eks-distro/kubernetes-csi/external-provisioner:v2.1.1-eks-1-19-2
          name: external-provisioner-image
          os: linux
          type: Image
      gitTag: v2.1.1
      name: external-provisioner
    - assets:
        - arch:
            - amd64
            - arm64
          description: external-resizer container image
          image:
            uri: public.ecr.aws/eks-distro/kubernetes-csi/external-resizer:v1.1.0-eks-1-19-2
          name: external-resizer-image
          os: linux
          type: Image
      gitTag: v1.1.0
      name: external-resizer
    - assets:
        - arch:
            - amd64
            - arm64
          description: node-driver-registrar container image
          image:
            uri: public.ecr.aws/eks-distro/kubernetes-csi/node-driver-registrar:v2.1.0-eks-1-19-2
          name: node-driver-registrar-image
          os: linux
          type: Image
      gitTag: v2.1.0
      name: node-driver-registrar
  date: "2021-03-27T04:36:52Z"

```
