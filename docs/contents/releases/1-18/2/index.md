# EKS-D v1-18-eks-2 Release

The [EKS-D v1-18-eks-2](https://distro.eks.amazonaws.com/kubernetes-1-18/kubernetes-1-18-eks-2.yaml)
release manifest defines the release used in EKS-D.

```yaml
---
apiVersion: distro.eks.amazonaws.com/v1alpha1
kind: Release
metadata:
  creationTimestamp: null
  name: kubernetes-1-18-eks-2
spec:
  channel: 1-18
  number: 2
status:
  components:
    - assets:
        - arch:
            - amd64
            - arm64
          description: metrics-server container image
          image:
            uri: public.ecr.aws/eks-distro/kubernetes-sigs/metrics-server:v0.4.0-eks-1-18-2
          name: metrics-server-image
          os: linux
          type: Image
      gitTag: v0.4.0
      name: metrics-server
    - assets:
        - arch:
            - arm64
          archive:
            sha256: 58b0bc76af0da6de87a1ef0919b2a88b6415cd42537a75596694d439973b5843
            sha512: b4bd436698f0bbe70b2688e5f75863a46150244d1df617cfd7f90af5b28e419e6376d813802d4869651b1bd29ef9f36160705a22b4a411fd644170a250c261b8
            uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/2/artifacts/plugins/v0.8.7/cni-plugins-linux-arm64-v0.8.7.tar.gz
          description: cni-plugins tarball for linux/arm64
          name: cni-plugins-linux-arm64-v0.8.7.tar.gz
          os: linux
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: e391387021f04db4f8cd18231ade4fe98c5d3f08721d2638b54d7ffadc4f03b0
            sha512: edb770fec6158c547f8713982069713b2fc5407707ff65ba8e6a677afc61a31670192add04792abaf9bd5614ab407ce10cc7c6f99f1daff6268c3551ac03885f
            uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/2/artifacts/plugins/v0.8.7/cni-plugins-linux-amd64-v0.8.7.tar.gz
          description: cni-plugins tarball for linux/amd64
          name: cni-plugins-linux-amd64-v0.8.7.tar.gz
          os: linux
          type: Archive
      gitTag: v0.8.7
      name: cni-plugins
    - assets:
        - arch:
            - amd64
            - arm64
          description: coredns container image
          image:
            uri: public.ecr.aws/eks-distro/coredns/coredns:v1.7.0-eks-1-18-2
          name: coredns-image
          os: linux
          type: Image
      gitTag: v1.7.0
      name: coredns
    - assets:
        - arch:
            - arm64
          archive:
            sha256: 28757af7532450f2f29f6e8c21f07aa4bc428ad50fe13872511ee2405b377297
            sha512: a29bd884d829574366a2cb789633545dd1e837ce69f54a6344bb27b05cdbdc9528f37e4225ff82aa621edb372c28d524d9a95b3aeccadb83dc4d96fa0cff2873
            uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/2/artifacts/kubernetes/v1.18.9/kubernetes-client-linux-arm64.tar.gz
          description: Kubernetes client tarball for linux/arm64
          name: kubernetes-client-linux-arm64.tar.gz
          os: linux
          type: Archive
        - arch:
            - arm64
          archive:
            sha256: ca52575efb3c2a146fbe5b6d0a91ab5997575184244f52b1e5632a3080df24b7
            sha512: 9ca1c3dae0654e3ed032e2e469592a621c830c490e940b80b5cc7e0d1fca0218a8d8a7482f7986d84d5215506eebe652a18240872189cd3ab905936697512f29
            uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/2/artifacts/kubernetes/v1.18.9/kubernetes-server-linux-arm64.tar.gz
          description: Kubernetes server tarball for linux/arm64
          name: kubernetes-server-linux-arm64.tar.gz
          os: linux
          type: Archive
        - arch:
            - arm64
          archive:
            sha256: 162252cf71f2b4e09f22f2c236fb636acfb986251460a80062f2ff09e54faf70
            sha512: 22c7483ca3fd31329c2ee47347feec68b9bdaba52331729418fe7d62ec0be94f1dc1348c7caf3b90aadc4ed23adaacdb44dd2faf1f5af9cd2248ff5ba564db51
            uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/2/artifacts/kubernetes/v1.18.9/kubernetes-node-linux-arm64.tar.gz
          description: Kubernetes node tarball for linux/arm64
          name: kubernetes-node-linux-arm64.tar.gz
          os: linux
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: 5d0957529f688620e0a97358554aa5988b6fa1462cc72d33815fc55fbed48970
            sha512: 5e65d1fa25bee44c44d64f7167d5cf03156c7e40980d207ca3cd5c668ceb71600ccbec650dd2b80295cdf377713573216fb139dfa177d537cf417b041b4de364
            uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/2/artifacts/kubernetes/v1.18.9/kubernetes-client-linux-amd64.tar.gz
          description: Kubernetes client tarball for linux/amd64
          name: kubernetes-client-linux-amd64.tar.gz
          os: linux
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: b67785a9ba0ff727879d4af513008f19aa190a2c9ebd1f7741c3e117a0fe15e3
            sha512: 6938fd814fe3f3194a56c6b99f543b9578ee75555691d300e45645d3c1dd9eb5658f2bb26020f8fa386453d2e763092f118547bea2a87ba06d9097cf5d9e9ef7
            uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/2/artifacts/kubernetes/v1.18.9/kubernetes-server-linux-amd64.tar.gz
          description: Kubernetes server tarball for linux/amd64
          name: kubernetes-server-linux-amd64.tar.gz
          os: linux
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: 089cd6ca88cd52637bf58f64d54d7bba553a45000a0e44b3c62b53bdf91d38ad
            sha512: d3d8bc87545fe77667bd14cfe28c2948cf4e55d57e8fe0dd7206c0b4f9fd6abe68567a53c19473ce51a0d80709a4cd7b1d93332fc2ddbc61021b1f3882634668
            uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/2/artifacts/kubernetes/v1.18.9/kubernetes-node-linux-amd64.tar.gz
          description: Kubernetes node tarball for linux/amd64
          name: kubernetes-node-linux-amd64.tar.gz
          os: linux
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: 02146204efe5a86c1412083056ed2a305dce8db0b2d65ef262bd30da89664fef
            sha512: c1f9d69c8254fd25aa2d98dcfde9eca7ca2c6c39c64cd15ec6605a17d55eecfcfee1669579f9d372581535d75ed1fef1cad09a985c91e4fa3235d1828b3007a1
            uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/2/artifacts/kubernetes/v1.18.9/kubernetes-client-windows-amd64.tar.gz
          description: Kubernetes client tarball for windows/amd64
          name: kubernetes-client-windows-amd64.tar.gz
          os: windows
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: 5a20c3c05204b49462b9515a48af312ede713d2ea2870a656b7af7bc5011347a
            sha512: b0c84dabe557e72950d4156b3fbeca2fc4ce9897d8d26cfcb5ce2b4e524d73003fd1bea563399dcc681e83b19af0cc2b371024e2d59214d76c6b703d9380a57f
            uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/2/artifacts/kubernetes/v1.18.9/kubernetes-node-windows-amd64.tar.gz
          description: Kubernetes node tarball for windows/amd64
          name: kubernetes-node-windows-amd64.tar.gz
          os: windows
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: cfc9e3aa2508dce7c0d4216b54b62d614f915e0d276bc8cd233a6b94228918be
            sha512: 6b6ef9f91109105cb402c422dc13b96df00472ee42b5c006c8ce756ee9ae851ff1d3e07b8c6494f0bcfc27c3711878642504b48f30ca0bc24c2b5c087ea2d61c
            uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/2/artifacts/kubernetes/v1.18.9/kubernetes-client-darwin-amd64.tar.gz
          description: Kubernetes client tarball for darwin/amd64
          name: kubernetes-client-darwin-amd64.tar.gz
          os: darwin
          type: Archive
        - arch:
            - amd64
            - arm64
          description: kube-apiserver container image
          image:
            uri: public.ecr.aws/eks-distro/kubernetes/kube-apiserver:v1.18.9-eks-1-18-2
          name: kube-apiserver-image
          os: linux
          type: Image
        - arch:
            - amd64
            - arm64
          description: kube-controller-manager container image
          image:
            uri: public.ecr.aws/eks-distro/kubernetes/kube-controller-manager:v1.18.9-eks-1-18-2
          name: kube-controller-manager-image
          os: linux
          type: Image
        - arch:
            - amd64
            - arm64
          description: kube-scheduler container image
          image:
            uri: public.ecr.aws/eks-distro/kubernetes/kube-scheduler:v1.18.9-eks-1-18-2
          name: kube-scheduler-image
          os: linux
          type: Image
        - arch:
            - amd64
            - arm64
          description: kube-proxy container image
          image:
            uri: public.ecr.aws/eks-distro/kubernetes/kube-proxy:v1.18.9-eks-1-18-2
          name: kube-proxy-image
          os: linux
          type: Image
        - arch:
            - amd64
            - arm64
          description: pause container image
          image:
            uri: public.ecr.aws/eks-distro/kubernetes/pause:v1.18.9-eks-1-18-2
          name: pause-image
          os: linux
          type: Image
        - arch:
            - arm64
          archive:
            sha256: 0e75f1e336da3542bfad22d643c8cdc4845c901f21e0baa1611ce6aac9ce7d56
            sha512: 0aa7483d1728494c75e09f886845f9bef14ac1f1b8eb3f7ffa65d2ad3b06c37acae91a02d6685fd16b3f0a37e351f42fe0d52aa6f66292777b9e3e234d22cb22
            uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/2/artifacts/kubernetes/v1.18.9/bin/linux/arm64/kube-apiserver
          description: kube-apiserver binary for linux/arm64
          name: bin/linux/arm64/kube-apiserver
          os: linux
          type: Archive
        - arch:
            - arm64
          archive:
            sha256: 92cdbf916e77dcc1f2f4d4516516151024bdd1cbd998f815d9c9734b855f1f54
            sha512: 957c13299be9f84bf00d1c08516e651fafec64f2c0b375c1389fb0183169c65412ab115bbfce052479d2343c54d25ec624fccb98a6d73007401a04b8f61d98f8
            uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/2/artifacts/kubernetes/v1.18.9/bin/linux/arm64/kube-controller-manager
          description: kube-controller-manager binary for linux/arm64
          name: bin/linux/arm64/kube-controller-manager
          os: linux
          type: Archive
        - arch:
            - arm64
          archive:
            sha256: d1913aab3794e9be8eaab95ee2c0f2580dc9f3b28526cb615015363c9ae05a94
            sha512: a7b4ff10b6500d548595acb97f8ce0a77990e1ecddf3c1440c578a79b410d0b5ec28dbdb9722409379ba37ff837fbb3bfe52865b3969842f76a21320908b2f4d
            uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/2/artifacts/kubernetes/v1.18.9/bin/linux/arm64/kube-proxy
          description: kube-proxy binary for linux/arm64
          name: bin/linux/arm64/kube-proxy
          os: linux
          type: Archive
        - arch:
            - arm64
          archive:
            sha256: 07fd71b7acd52ec938df3db69d06febde70d831a59241f79cbf6ba73f1ccd831
            sha512: a73f0118ba7328cf27384b00be657bcd61bdd6d2c14ce16e2eef57be0d7f4774f1ea31b9f516139ca589d1cd2c823ebb74a84ad06da4b85be7154f4145a41bba
            uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/2/artifacts/kubernetes/v1.18.9/bin/linux/arm64/kube-scheduler
          description: kube-scheduler binary for linux/arm64
          name: bin/linux/arm64/kube-scheduler
          os: linux
          type: Archive
        - arch:
            - arm64
          archive:
            sha256: 212abb9abdca983a58d6a5bbd6f44a680fb3bee54b097b728e268f96825aa9d5
            sha512: f9d0aa9f3a3ef29c79f53fec88f2c35829f849c5ce9734447f87dfbc4e2d490ecb4d25f5383ab8471e6e472467dc2554fc4995ae9cea32a1b39dd7fae3f133b0
            uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/2/artifacts/kubernetes/v1.18.9/bin/linux/arm64/kubectl
          description: kubectl binary for linux/arm64
          name: bin/linux/arm64/kubectl
          os: linux
          type: Archive
        - arch:
            - arm64
          archive:
            sha256: 0d3cac4ba956d7515a1ea17a18f1f88e1a1fe2744fed782c05e6017545ea6da1
            sha512: dca2c3c14849ff0158a8ad50551d3d5c3d67594e30649db4f2c65e06d6d34b393e310b8c0f243e51c5454249a91062c6326c230b1c6cab9c68e6912a8c48d027
            uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/2/artifacts/kubernetes/v1.18.9/bin/linux/arm64/kubelet
          description: kubelet binary for linux/arm64
          name: bin/linux/arm64/kubelet
          os: linux
          type: Archive
        - arch:
            - arm64
          archive:
            sha256: 5c2206dc2dc3226484b21bb2ba897aab365fae0b8f4ef784631a6b952417da66
            sha512: 5cb1093333066156abcf1c0aec5bde2eec444f06e129db54e00ed8724d55400b9a7678578e2b6760dac1fd90b4075757a87b864deb96280eaf9466c6fd2f00e5
            uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/2/artifacts/kubernetes/v1.18.9/bin/linux/arm64/kubeadm
          description: kubeadm binary for linux/arm64
          name: bin/linux/arm64/kubeadm
          os: linux
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: 0bc72f960f9a907a0e864ec8c212da253522d6c3022a606a4b7194492ca820c3
            sha512: aaf9dc8f246f90dc823f793a97aed19296a6afcd4709da60e85fceae44b91c0f3f9bbb934b741be22cb35c3622e72eaa2a108b68b8f7a9d352ed347e832e9424
            uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/2/artifacts/kubernetes/v1.18.9/bin/linux/amd64/kube-apiserver
          description: kube-apiserver binary for linux/amd64
          name: bin/linux/amd64/kube-apiserver
          os: linux
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: bbe3a3a83b1a36f2e05b5727814d7292cd8e713334c8e8652e2aa8a3276fa8e3
            sha512: ef4773e90e332c20990131018e9da343493a1a890232f49f92eaff8a806ef25eafa0042762e7beaa6f201f09aa46bba0894d562bb551846cd6731ec2f846cf35
            uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/2/artifacts/kubernetes/v1.18.9/bin/linux/amd64/kube-controller-manager
          description: kube-controller-manager binary for linux/amd64
          name: bin/linux/amd64/kube-controller-manager
          os: linux
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: bcb077e388fb739a76c6384774760b1fc4663483b27b138c6de2731d1a46482f
            sha512: 395837e3cf4cf01c8aeeadb5a6ab3af285c57333b46a47f25e909bfa2980ba5f0bc3f2bfdbcb7ac685d7745e38275d944054d26ebd3ef7b39b3b5ba3ec7f5996
            uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/2/artifacts/kubernetes/v1.18.9/bin/linux/amd64/kube-proxy
          description: kube-proxy binary for linux/amd64
          name: bin/linux/amd64/kube-proxy
          os: linux
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: bc10076d6b5a402b663c629522dad7a5f086044e3203c93e7e772e1a154a3aad
            sha512: 2f2f3f8baf45dc4a0536a4171213ae8c9df20464cb266d95ac6cb31d537d3992d7d6f6ec16e9f275b2d75473d38bdad3d2771abc752dd2ab96561027bdc5d8d0
            uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/2/artifacts/kubernetes/v1.18.9/bin/linux/amd64/kube-scheduler
          description: kube-scheduler binary for linux/amd64
          name: bin/linux/amd64/kube-scheduler
          os: linux
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: 18aec74b07f440a49d3f92e78b15357e47e82a05da2d2cc62e0f19e4cabaaefd
            sha512: f938fe688caa87c93220b950304ea9c072cedf0b0b3b1ae898981bb864648d21802b4fe50a8706e11967ee15fd61aeb338868c54f4bfedcbfdcf14206eb8e441
            uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/2/artifacts/kubernetes/v1.18.9/bin/linux/amd64/kubectl
          description: kubectl binary for linux/amd64
          name: bin/linux/amd64/kubectl
          os: linux
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: c287773a96ffc29b8aaddd4023d67a1392247f4d9c55d2a67dcba49d36d7d0be
            sha512: 0c03abda1cee3ad8a07edad94a061a0d6278906fb3c556c62831aa59a219fc776e2b59bb33cc9095c1b304b9f93cda883098ed97b5ce6eb0e6cf9184289423d4
            uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/2/artifacts/kubernetes/v1.18.9/bin/linux/amd64/kubelet
          description: kubelet binary for linux/amd64
          name: bin/linux/amd64/kubelet
          os: linux
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: 41cd9c0518076e5c2a208053dc58833b2312e3229d40ecb130279bd3494fc8af
            sha512: 367e8caf7f5da37f671da1270bc3a3a3be1bef10c1deb59cf3f3397076c50999f0f4d3aca4a5112787ff017d45b3ebdb67a2d458bc6c0590b5d62d406cf8f4b6
            uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/2/artifacts/kubernetes/v1.18.9/bin/linux/amd64/kubeadm
          description: kubeadm binary for linux/amd64
          name: bin/linux/amd64/kubeadm
          os: linux
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: d303ee261b977e669ac2a95a83ad49788fd0a6ca9152c77e1e27b67690014030
            sha512: 7fdf5f87da2ead48c85a330ad40741cad6a9f5624684bb885d43fcbd96788be2c8e7918e7d0d2a7f1121150254bc138f3162c334a138058a6c0782d0fe8e0fd9
            uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/2/artifacts/kubernetes/v1.18.9/bin/windows/amd64/kube-proxy.exe
          description: kube-proxy.exe binary for windows/amd64
          name: bin/windows/amd64/kube-proxy.exe
          os: windows
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: 4ce49030f2003683c5f21403981cd0a0e657c57ca9b49a626741e490d56ce801
            sha512: b4ee0d5cee56ad5318e222eed87e7fa51545dc8ad62c03b8324211b4be6f53585ba6e3b39f34b3e41e78749fa57890d4b0f94ccda00f2f5b653dc862a297fcf9
            uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/2/artifacts/kubernetes/v1.18.9/bin/windows/amd64/kubeadm.exe
          description: kubeadm.exe binary for windows/amd64
          name: bin/windows/amd64/kubeadm.exe
          os: windows
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: 68469dc6bf7345b0fc9fe0e02a7bbbe1794c31885731480dd5ebc3f9595dcbe2
            sha512: 07ea89ade63374a11c0c732e93bca815d5ac666b1a48a2185c7220f497d0f1216f9acf650fbd46ba52146129f3157b8d29dfb841a4685b7f7cd2f5ea6b18afe1
            uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/2/artifacts/kubernetes/v1.18.9/bin/windows/amd64/kubectl.exe
          description: kubectl.exe binary for windows/amd64
          name: bin/windows/amd64/kubectl.exe
          os: windows
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: d16b0335e61be8ea71b90a3da71280cef3ce12c0a6106828ca5f7ce66259918c
            sha512: 957addb40d6915d676785ae89215577c9ba1a482a1c986a3286353b76abb8a5076f56ca7b4c82fb81b86b1ee6f79ff37b7d9d210fbfed031bb2e270a138cc7c7
            uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/2/artifacts/kubernetes/v1.18.9/bin/windows/amd64/kubelet.exe
          description: kubelet.exe binary for windows/amd64
          name: bin/windows/amd64/kubelet.exe
          os: windows
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: b59b7feef5d8e9aa786a9532563991b36310b4b9964963112e8b8c8d19a57c31
            sha512: 6e37541c74eba54e9a69978f4d738aca4f920811230703f0d5c39221f32fe33384add2e2a200fd714c57feff53e7601a1dac0b44e0941425908abde3a8fae0b4
            uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/2/artifacts/kubernetes/v1.18.9/bin/darwin/amd64/kubectl
          description: kubectl binary for darwin/amd64
          name: bin/darwin/amd64/kubectl
          os: darwin
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: a45cf9abab25f441138b47fb8b1cbfeef363cd046b49c908c3e15c0fefa1d1dc
            sha512: a3b78bb3c249cad6e315e6afc5eeb03c9d62ea0229436559aa47a44bd85ec7d39e81480b1b21e779242db8549d3811ccdfbeb347b4d09987bfd6c1f561ed4696
            uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/2/artifacts/kubernetes/v1.18.9/bin/linux/amd64/kube-apiserver.tar
          description: kube-apiserver linux/amd64 OCI image tar
          name: bin/linux/amd64/kube-apiserver.tar
          os: linux
          type: Archive
        - arch:
            - arm64
          archive:
            sha256: 2da180ebea81f03f6cf56cd438ed35febfbe1b1eb7b02f0dac5681df593827a2
            sha512: c1b3c6c12f30d69a26db1b35c8529674bf81b4ad8a38dbcd27f36fd2184179b7649d082035d624a12ab68f466f2bc6d00cb30f513326ef4c78ef5a716438715e
            uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/2/artifacts/kubernetes/v1.18.9/bin/linux/arm64/kube-apiserver.tar
          description: kube-apiserver linux/arm64 OCI image tar
          name: bin/linux/arm64/kube-apiserver.tar
          os: linux
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: 7a323b12b0b30e8cc3c7cebbe506355a57ec6587333484dabfdb5e0a2698f46a
            sha512: e9d2197ab2d281209ee2b588311006020143c10d1a7939eb13dd8bc6559f265dfd41c7a97c016147c07bcab62c15f9e2d6aad8348fb6d55d2a290791b6378d53
            uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/2/artifacts/kubernetes/v1.18.9/bin/linux/amd64/kube-controller-manager.tar
          description: kube-controller-manager linux/amd64 OCI image tar
          name: bin/linux/amd64/kube-controller-manager.tar
          os: linux
          type: Archive
        - arch:
            - arm64
          archive:
            sha256: dde27ecf339846ee3902e29d965c61b31c90d8ad85c099b0336580f549d4a09c
            sha512: 14cc4d5e38b86b308463bc41c52f2494ab300d1ba2f6b4f6bd1d347318e36263b8137d225bf8e71ccbc242254be15ae9dda6c0af64018984949c86cc8f28c3cd
            uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/2/artifacts/kubernetes/v1.18.9/bin/linux/arm64/kube-controller-manager.tar
          description: kube-controller-manager linux/arm64 OCI image tar
          name: bin/linux/arm64/kube-controller-manager.tar
          os: linux
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: 12506eade45e494f54216dc9c0ee20fbe81edf54fea6be439e88515bcd369eb0
            sha512: 235e4583cd5d32c925595e8f9fb0a4238e024e929a099fce1755bb39114106345d4acec14f8278d1c0eec51d92024c64443730ccbab67b2520400fcb7d974b55
            uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/2/artifacts/kubernetes/v1.18.9/bin/linux/amd64/kube-scheduler.tar
          description: kube-scheduler linux/amd64 OCI image tar
          name: bin/linux/amd64/kube-scheduler.tar
          os: linux
          type: Archive
        - arch:
            - arm64
          archive:
            sha256: 222a6b9f4490cb829017cf3664ca2c1dd726f2aa040f4739d488e392ea15a85b
            sha512: 16cc932a0bfc8a4ab2af89dc0af10694bacfb2249d790b7be5aba2bbedb14caf3343d933ac1785bf488c96365bd4816c087e7bd9bf00245d94525d36ec80b5ac
            uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/2/artifacts/kubernetes/v1.18.9/bin/linux/arm64/kube-scheduler.tar
          description: kube-scheduler linux/arm64 OCI image tar
          name: bin/linux/arm64/kube-scheduler.tar
          os: linux
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: a7ef6b4868255a89f3dcc07d0cbb5c68290285459f5cdb2f8437e8a48bff1ad2
            sha512: 20c96f14ed98a2309eaebe609340f80a4c7493ec0bd55c52acd55cce1e724f5751e20ecf173758af24f84d09ddb6a9486630813d076954c8b11a5dd82fa45c49
            uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/2/artifacts/kubernetes/v1.18.9/bin/linux/amd64/kube-proxy.tar
          description: kube-proxy linux/amd64 OCI image tar
          name: bin/linux/amd64/kube-proxy.tar
          os: linux
          type: Archive
        - arch:
            - arm64
          archive:
            sha256: 263884abbbd4b1fd2770fb74312d2a9fcf202261e1a1c32f284847193d4278a8
            sha512: 9041f45ebe2e342371444db3399d86b365414a261e984c4792865ba02c01087521bf13662e8029af3a9dfc74388bea048a6e1ede10693a36e6564619e1c1493f
            uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/2/artifacts/kubernetes/v1.18.9/bin/linux/arm64/kube-proxy.tar
          description: kube-proxy linux/arm64 OCI image tar
          name: bin/linux/arm64/kube-proxy.tar
          os: linux
          type: Archive
        - archive:
            sha256: 968458c084f89d1e0f09a86bffc318d7d56ffa343f19d4752832c01194c5104e
            sha512: 010fef210093a99036f985bdbf2e145da593d1c32480a8149ea01e8d8bf2c46a60ef43d82db7fd1dcee830d3700c86235ef5e5ce42364125ad2ca15bc698e4ff
            uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/2/artifacts/kubernetes/v1.18.9/kubernetes-src.tar.gz
          description: Kubernetes source tarball
          name: kubernetes-src.tar.gz
          type: Archive
      gitCommit: 94f372e501c973a7fa9eb40ec9ebd2fe7ca69848
      gitTag: v1.18.9
      name: kubernetes
    - assets:
        - arch:
            - amd64
            - arm64
          description: external-provisioner container image
          image:
            uri: public.ecr.aws/eks-distro/kubernetes-csi/external-provisioner:v2.1.1-eks-1-18-2
          name: external-provisioner-image
          os: linux
          type: Image
      gitTag: v2.1.1
      name: external-provisioner
    - assets:
        - arch:
            - amd64
            - arm64
          description: csi-snapshotter container image
          image:
            uri: public.ecr.aws/eks-distro/kubernetes-csi/external-snapshotter/csi-snapshotter:v3.0.3-eks-1-18-2
          name: csi-snapshotter-image
          os: linux
          type: Image
        - arch:
            - amd64
            - arm64
          description: snapshot-controller container image
          image:
            uri: public.ecr.aws/eks-distro/kubernetes-csi/external-snapshotter/snapshot-controller:v3.0.3-eks-1-18-2
          name: snapshot-controller-image
          os: linux
          type: Image
        - arch:
            - amd64
            - arm64
          description: snapshot-validation-webhook container image
          image:
            uri: public.ecr.aws/eks-distro/kubernetes-csi/external-snapshotter/snapshot-validation-webhook:v3.0.3-eks-1-18-2
          name: snapshot-validation-webhook-image
          os: linux
          type: Image
      gitTag: v3.0.3
      name: external-snapshotter
    - assets:
        - arch:
            - amd64
            - arm64
          description: external-resizer container image
          image:
            uri: public.ecr.aws/eks-distro/kubernetes-csi/external-resizer:v1.1.0-eks-1-18-2
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
            uri: public.ecr.aws/eks-distro/kubernetes-csi/node-driver-registrar:v2.1.0-eks-1-18-2
          name: node-driver-registrar-image
          os: linux
          type: Image
      gitTag: v2.1.0
      name: node-driver-registrar
    - assets:
        - arch:
            - arm64
          archive:
            sha256: 9fca18f3eab56c11fceb535dbc569e35306900d4ea4bae79a2bf5b26de1e225a
            sha512: 2353583a13c9f33f00823ccf0ff66acafa8addff3a3873bc658ed5c3a642c04b5ae9828a5897343fff8a9f7e0285df582ba4ffbeae70496861f9dc0090b9f695
            uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/2/artifacts/etcd/v3.4.14/etcd-linux-arm64-v3.4.14.tar.gz
          description: etcd tarball for linux/arm64
          name: etcd-linux-arm64-v3.4.14.tar.gz
          os: linux
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: 3a326d99a8865c2173e34e47717d44a76bc47ffba9506c83b22123a79f344bf4
            sha512: 1847c6d6ead36543f1aff4f7055b0c0fa994d190c5756e352b4b65be0d488269c59873836f33201b90a8c8efd1f01b84bda10eaea20537c5ff29c68ee95179d5
            uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/2/artifacts/etcd/v3.4.14/etcd-linux-amd64-v3.4.14.tar.gz
          description: etcd tarball for linux/amd64
          name: etcd-linux-amd64-v3.4.14.tar.gz
          os: linux
          type: Archive
        - arch:
            - amd64
            - arm64
          description: etcd container image
          image:
            uri: public.ecr.aws/eks-distro/etcd-io/etcd:v3.4.14-eks-1-18-2
          name: etcd-image
          os: linux
          type: Image
      gitTag: v3.4.14
      name: etcd
    - assets:
        - arch:
            - amd64
          archive:
            sha256: dd87bc539187f778aa1ef4692a63c828b9a90f9c62df83cd02205622adc87c8c
            sha512: a8ef1bd2d3a0bf50397e7863a6033d8641543358e0bc8c5eda733f085f35487b4aa53819f8dd06e8f19877f4826f6eb796e9b3c871023daf6a40aa30cd3a5399
            uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/2/artifacts/aws-iam-authenticator/v0.5.2/aws-iam-authenticator-darwin-amd64-v0.5.2.tar.gz
          description: aws-iam-authenticator tarball for darwin/amd64
          name: aws-iam-authenticator-darwin-amd64-v0.5.2.tar.gz
          os: darwin
          type: Archive
        - arch:
            - arm64
          archive:
            sha256: 8bdd5612be6b2ebfaa86f69c7e58013fafd6def89b0fe73c9d4eaa49cc8ca54a
            sha512: 8d9abd60b3721648fb6c35923ce3163677ef86ac246a37dfc63430c16fd5293f33d92be13023216bba441be792d262eb41517489dba600c4b34eeb411a71b2a2
            uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/2/artifacts/aws-iam-authenticator/v0.5.2/aws-iam-authenticator-linux-arm64-v0.5.2.tar.gz
          description: aws-iam-authenticator tarball for linux/arm64
          name: aws-iam-authenticator-linux-arm64-v0.5.2.tar.gz
          os: linux
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: 10b6442cdaf5be8d23cd883583572375050a46586872d97e54f5b2a91298c76e
            sha512: b9065dc3fb1e4909169cef11685b8e9383aca885f8cf45e7f43258800f3277c8cc861110986937835dac13dff070941d4cdb4d95daf0818f1bf4e71fea6e6ca4
            uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/2/artifacts/aws-iam-authenticator/v0.5.2/aws-iam-authenticator-linux-amd64-v0.5.2.tar.gz
          description: aws-iam-authenticator tarball for linux/amd64
          name: aws-iam-authenticator-linux-amd64-v0.5.2.tar.gz
          os: linux
          type: Archive
        - arch:
            - amd64
          archive:
            sha256: 3011df0bbfc96c5e68dbbf5a4ec46644186d1ab8f6cd6c1fb06fdbf0885bd286
            sha512: 7c2b1d247deb6696469140e86ebba3c69e5048422729fb6bfe72fd17bc8e82a58cd394fefae7aaf71c65f09a8c3b8c8f63650b55143bdcc3aeec6b5b8986406d
            uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/2/artifacts/aws-iam-authenticator/v0.5.2/aws-iam-authenticator-windows-amd64-v0.5.2.tar.gz
          description: aws-iam-authenticator tarball for windows/amd64
          name: aws-iam-authenticator-windows-amd64-v0.5.2.tar.gz
          os: windows
          type: Archive
        - arch:
            - amd64
            - arm64
          description: aws-iam-authenticator container image
          image:
            uri: public.ecr.aws/eks-distro/kubernetes-sigs/aws-iam-authenticator:v0.5.2-eks-1-18-2
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
            uri: public.ecr.aws/eks-distro/kubernetes-csi/livenessprobe:v2.2.0-eks-1-18-2
          name: livenessprobe-image
          os: linux
          type: Image
      gitTag: v2.2.0
      name: livenessprobe
    - assets:
        - arch:
            - amd64
            - arm64
          description: external-attacher container image
          image:
            uri: public.ecr.aws/eks-distro/kubernetes-csi/external-attacher:v3.1.0-eks-1-18-2
          name: external-attacher-image
          os: linux
          type: Image
      gitTag: v3.1.0
      name: external-attacher
  date: "2021-03-26T22:45:28Z"

```
