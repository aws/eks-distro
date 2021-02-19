# EKS-D v1-18-eks-1 Release

The [EKS-D v1-18-eks-1](https://distro.eks.amazonaws.com/kubernetes-1-18/kubernetes-1-18-eks-1.yaml)
CRD (Custom Release Document) defines the release used in EKS-D.

```yaml
---
apiVersion: distro.eks.amazonaws.com/v1alpha1
kind: Release
metadata:
  creationTimestamp: null
  name: kubernetes-1-18-eks-1
spec:
  buildRepoCommit: ad17bb9c2b29c32d0173006f949ea012373a86f4
  channel: 1-18
  number: 1
status:
  components:
  - assets:
    - arch:
      - amd64
      - arm64
      description: metrics-server container image
      image:
        uri: public.ecr.aws/eks-distro/kubernetes-sigs/metrics-server:v0.4.0-eks-1-18-1
      name: metrics-server-image
      os: linux
      type: Image
    gitTag: v0.4.0
    name: metrics-server
  - assets:
    - arch:
      - arm64
      archive:
        sha256: 779aed2c51cd2d1a8f361af8a477dd7ae818996167258e0a07f99a9f48b0881c
        sha512: 3e26a7157fad105725d017f01e95d71f5b518d29ed13e56992e03c092c7a1527091ac1d53b3db97413a5c346104a0a09770f1ff90598cfdf6187b4edda40394a
        uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/etcd/v3.4.14/etcd-linux-arm64-v3.4.14.tar.gz
      description: etcd tarball for linux/arm64
      name: etcd-linux-arm64-v3.4.14.tar.gz
      os: linux
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: 76cca74ecd4afd25d9fb4455153b9a0212d6e7b65d2d417f6240bf76677c3712
        sha512: 373f2f473c6667b81f179fa81a967e6bccbf6ab3a26abbd8a3955a983b74cf4d5127c43806e16e2d7121c6924a2ad83dc417fe8cfa1c0955859b4770ba3b5efe
        uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/etcd/v3.4.14/etcd-linux-amd64-v3.4.14.tar.gz
      description: etcd tarball for linux/amd64
      name: etcd-linux-amd64-v3.4.14.tar.gz
      os: linux
      type: Archive
    - arch:
      - amd64
      - arm64
      description: etcd container image
      image:
        uri: public.ecr.aws/eks-distro/etcd-io/etcd:v3.4.14-eks-1-18-1
      name: etcd-image
      os: linux
      type: Image
    gitTag: v3.4.14
    name: etcd
  - assets:
    - arch:
      - amd64
      - arm64
      description: livenessprobe container image
      image:
        uri: public.ecr.aws/eks-distro/kubernetes-csi/livenessprobe:v2.1.0-eks-1-18-1
      name: livenessprobe-image
      os: linux
      type: Image
    gitTag: v2.1.0
    name: livenessprobe
  - assets:
    - arch:
      - amd64
      - arm64
      description: external-attacher container image
      image:
        uri: public.ecr.aws/eks-distro/kubernetes-csi/external-attacher:v3.0.1-eks-1-18-1
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
        uri: public.ecr.aws/eks-distro/kubernetes-csi/external-provisioner:v2.0.3-eks-1-18-1
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
        uri: public.ecr.aws/eks-distro/kubernetes-csi/external-resizer:v1.0.1-eks-1-18-1
      name: external-resizer-image
      os: linux
      type: Image
    gitTag: v1.0.1
    name: external-resizer
  - assets:
    - arch:
      - arm64
      archive:
        sha256: 9dc7f7fa9a6ecd5c644101f5bb44bd2d9575f20932d3de2b30bac134731b09f7
        sha512: b158df4930e861627742d549867a37ee7c069ea51867fbfaaab95c950753ffc1b8acef43883f1928bed81f697e12cb394c54f11b38f09791407e93c9dc3ae79b
        uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/plugins/v0.8.7/cni-plugins-linux-arm64-v0.8.7.tar.gz
      description: cni-plugins tarball for linux/arm64
      name: cni-plugins-linux-arm64-v0.8.7.tar.gz
      os: linux
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: 7426431524c2976f481105b80497238030e1c3eedbfcad00e2a9ccbaaf9eef9d
        sha512: af5a9527ca03d803baffcc653f370d155de68cdf12d16dbbfc246148d3f7ec089c8a8f82d841e0e95f8d3845dde95537499d7b7e4759aafab3cae5f0bafed16a
        uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/plugins/v0.8.7/cni-plugins-linux-amd64-v0.8.7.tar.gz
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
        uri: public.ecr.aws/eks-distro/coredns/coredns:v1.7.0-eks-1-18-1
      name: coredns-image
      os: linux
      type: Image
    gitTag: v1.7.0
    name: coredns
  - assets:
    - arch:
      - arm64
      archive:
        sha256: e94e4a57cfd1b79764db6bc2415e18af044e6b1768b4694358abc28c8b430648
        sha512: 622484ec8aa7dd223c569d32e3712956724114ecde7dc2de607b60023758658aaf518f6ac599d02eb88e0864a4d47b206e416922fe6d9a942534d084d234b6e9
        uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/kubernetes/v1.18.9/kubernetes-client-linux-arm64.tar.gz
      description: Kubernetes client tarball for linux/arm64
      name: kubernetes-client-linux-arm64.tar.gz
      os: linux
      type: Archive
    - arch:
      - arm64
      archive:
        sha256: 9dd2ba45bee72224dfee3b51c8d7b7420ff0a980eccb343033f4ff5518479a20
        sha512: 91f6465046187db691b88bcda4cfe7777b66f7be595837413eec704703f263c7dfda3fee394bfa53698236fefb58aaf936bff8e43d05ab83188fc231c504f1a3
        uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/kubernetes/v1.18.9/kubernetes-server-linux-arm64.tar.gz
      description: Kubernetes server tarball for linux/arm64
      name: kubernetes-server-linux-arm64.tar.gz
      os: linux
      type: Archive
    - arch:
      - arm64
      archive:
        sha256: 42d39fd90e40f63899c9993ee79aa71c9494775f4a131be48014a01e1438cfd9
        sha512: 643a315ad1bb1ea5b1c488316880c188b286fb1422dac1f33a21a64ddb70621f158f3414a474e7727f833d6800ff04fdfd81ca59973ad63e204c662843672c09
        uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/kubernetes/v1.18.9/kubernetes-node-linux-arm64.tar.gz
      description: Kubernetes node tarball for linux/arm64
      name: kubernetes-node-linux-arm64.tar.gz
      os: linux
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: 6bc206b505c5c783df71b7bac4969bd1ce6577cb1dbf51a36bded108788e4dbb
        sha512: 2984515027bf9449f31cd7d20ffbd25db7fd898a36fb196783d2e95e905b06cc9eb35e4a7c29dd63da99a912ee050a4b1ca8e43d9e581958a2fa71bab46785d6
        uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/kubernetes/v1.18.9/kubernetes-client-linux-amd64.tar.gz
      description: Kubernetes client tarball for linux/amd64
      name: kubernetes-client-linux-amd64.tar.gz
      os: linux
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: ce25c1ad03aeef41897400721ee5deb0004683166096166f6f8053eee7814c9e
        sha512: 9c9574d6f9f481f3e9f277cedab6e539e5efbc4b6434f307abf9b9228a2d3abc1de068ebe556173d4470a77e59123578898f1981ead3f19b2588aa17ce6aea81
        uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/kubernetes/v1.18.9/kubernetes-server-linux-amd64.tar.gz
      description: Kubernetes server tarball for linux/amd64
      name: kubernetes-server-linux-amd64.tar.gz
      os: linux
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: af8302478a56f8872614627340b20ddf08d7dc0055f9600e78246f3df3a56d01
        sha512: 878c9e13eb36891c7cc734bed75120b120a329b3c1cbe44b4754de0f0eea60de83120ef8b8225eee2b8fc6f6105e6dce5bd9658b2809f77dee51ed48e2374a92
        uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/kubernetes/v1.18.9/kubernetes-node-linux-amd64.tar.gz
      description: Kubernetes node tarball for linux/amd64
      name: kubernetes-node-linux-amd64.tar.gz
      os: linux
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: eaa5d9d245b9a47cecdc46276af487d605dbf6f2b1386fdfcab52e9c6c745f72
        sha512: fec8418a117ec1a29c6be6f1ef64b490a867d0fe383dbd3d0677dcfca162302daad3b364fca0a8836415f4f68edce8cb76d2d2b16f69c8a421d751bae2836ba8
        uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/kubernetes/v1.18.9/kubernetes-client-windows-amd64.tar.gz
      description: Kubernetes client tarball for windows/amd64
      name: kubernetes-client-windows-amd64.tar.gz
      os: windows
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: ccce61fc2f4eb0d5e0a38637d3a4e0c1ef19b8eb52fa0bf7cd122be55d66dff5
        sha512: 5313f1af80a774353c74d03e5ba4ca7c02c7d750029522cd470a0dd3978316e8d3eb91027e186cb6aaac278acfc83456a97c87f8cfcfbe4c075396560360ca32
        uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/kubernetes/v1.18.9/kubernetes-node-windows-amd64.tar.gz
      description: Kubernetes node tarball for windows/amd64
      name: kubernetes-node-windows-amd64.tar.gz
      os: windows
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: b2e5379d1a9de3940b3a397b46d24cf0b940502918c46c3b89e92d017de27bca
        sha512: 7a5c1e596f1aca6ce85e08fe2b6079301a0f1432260cb879cdb735dfba7e61b03b384ee67c1d8d16394f56633ecf3e41574c1f5068d1ecb19016749238b2321e
        uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/kubernetes/v1.18.9/kubernetes-client-darwin-amd64.tar.gz
      description: Kubernetes client tarball for darwin/amd64
      name: kubernetes-client-darwin-amd64.tar.gz
      os: darwin
      type: Archive
    - arch:
      - amd64
      - arm64
      description: kube-apiserver container image
      image:
        uri: public.ecr.aws/eks-distro/kubernetes/kube-apiserver:v1.18.9-eks-1-18-1
      name: kube-apiserver-image
      os: linux
      type: Image
    - arch:
      - amd64
      - arm64
      description: kube-controller-manager container image
      image:
        uri: public.ecr.aws/eks-distro/kubernetes/kube-controller-manager:v1.18.9-eks-1-18-1
      name: kube-controller-manager-image
      os: linux
      type: Image
    - arch:
      - amd64
      - arm64
      description: kube-scheduler container image
      image:
        uri: public.ecr.aws/eks-distro/kubernetes/kube-scheduler:v1.18.9-eks-1-18-1
      name: kube-scheduler-image
      os: linux
      type: Image
    - arch:
      - amd64
      - arm64
      description: kube-proxy container image
      image:
        uri: public.ecr.aws/eks-distro/kubernetes/kube-proxy:v1.18.9-eks-1-18-1
      name: kube-proxy-image
      os: linux
      type: Image
    - arch:
      - amd64
      - arm64
      description: pause container image
      image:
        uri: public.ecr.aws/eks-distro/kubernetes/pause:v1.18.9-eks-1-18-1
      name: pause-image
      os: linux
      type: Image
    - arch:
      - arm64
      archive:
        sha256: c4bd495f2c0bab164b9063118c2e62d8e442b350acff996360c117f3fc45999c
        sha512: d72fe3f1309ed7317f8698e0aa6167855d89cb5124a49e19f23b75b4e1726455ec5ae0fabbd7a6b9f5ae609d1f0db129f79b4497972bb433263b2571e0c340de
        uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/kubernetes/v1.18.9/bin/linux/arm64/kube-apiserver
      description: kube-apiserver binary for linux/arm64
      name: bin/linux/arm64/kube-apiserver
      os: linux
      type: Archive
    - arch:
      - arm64
      archive:
        sha256: 489bd3444d64d027047b17d9c4953e3f928831a40a0e785f9b9091933b9bf359
        sha512: 3da4e0aeb05d9dbe1693000783e83f6adde5ea3a26276a60c629b6b24d595eca9fc2ca48630735d48066801050adbbbdad4ab0746f605e286d185952b27f19f6
        uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/kubernetes/v1.18.9/bin/linux/arm64/kube-controller-manager
      description: kube-controller-manager binary for linux/arm64
      name: bin/linux/arm64/kube-controller-manager
      os: linux
      type: Archive
    - arch:
      - arm64
      archive:
        sha256: 6f5d08d39c0a38637ce0b17044c9d355d2b4b8ff69f5143d338f489133e1fdd9
        sha512: e0288d0bff8a37a1e384fd2496629331969e1c46c3f247adb3483a67c7aa914a30011e3fbff5febb83142ea1a91e9dd61c9a175069e756449d26ef0651a1aa55
        uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/kubernetes/v1.18.9/bin/linux/arm64/kube-proxy
      description: kube-proxy binary for linux/arm64
      name: bin/linux/arm64/kube-proxy
      os: linux
      type: Archive
    - arch:
      - arm64
      archive:
        sha256: 0cba20504650e388e3643b4a112f27fcb1d2e2a3186d4cc963de46f839cc7b53
        sha512: 8626bd55475f5817411e633aa39661906d7e9a1b15be4210091fc5c9493ebb5fa395290260ff3ecfbca310569d9a3059fa21335ccda8d98dd0687785b768c26c
        uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/kubernetes/v1.18.9/bin/linux/arm64/kube-scheduler
      description: kube-scheduler binary for linux/arm64
      name: bin/linux/arm64/kube-scheduler
      os: linux
      type: Archive
    - arch:
      - arm64
      archive:
        sha256: bf5f7a11221a2e7017429e258c62beb32ae0da64c7951f19dbdd251e486a9cb7
        sha512: 0d128675506333bf4c47e1e13e777647f8b07bc7621985ef666b4cb626cfa629dcb0cb1014424f990f298a4fb9b37ca85f2f37126850302a3e36dccd9825a4cc
        uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/kubernetes/v1.18.9/bin/linux/arm64/kubectl
      description: kubectl binary for linux/arm64
      name: bin/linux/arm64/kubectl
      os: linux
      type: Archive
    - arch:
      - arm64
      archive:
        sha256: 6e1b3a09b99d1e4c2ddd5c4ffeaae185ec3c0495a49f59b4d1fe56dca171f7e1
        sha512: 45d41837e5e2fa515034650b248f687d5dd5b2a1a9be56c8a22e4d457e1a7e5d2b4967e358f6dd37b97dde0daa8adf2b8988cc33a6f0a3aefc35d6fc81f1225d
        uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/kubernetes/v1.18.9/bin/linux/arm64/kubelet
      description: kubelet binary for linux/arm64
      name: bin/linux/arm64/kubelet
      os: linux
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: f8ecf8ecd83f370ea5b7b96f0e88a7d549e0ecf3c848de6096ec3390d7703634
        sha512: eb761a80d93035a4392dbbdc8e5ba2fee341c8e834b8a1c1a4423ec53122f20305b29147640bb151cf21602564ecc3a995d635c9d80bdd7635a3ac1f0c5d9cce
        uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/kubernetes/v1.18.9/bin/linux/amd64/kube-apiserver
      description: kube-apiserver binary for linux/amd64
      name: bin/linux/amd64/kube-apiserver
      os: linux
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: 58271aa7b046376dd3eb3fd187bf934e70f14a44226a83b1832e979c81b6081d
        sha512: a0d96f258bbaf807e3adc95f021de2e3d03d293dfe94c65c20199f3401e4302d568ad62afc19c02c3d1c3f847166d119f16ddfda5bb770037acfd6a2789b3514
        uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/kubernetes/v1.18.9/bin/linux/amd64/kube-controller-manager
      description: kube-controller-manager binary for linux/amd64
      name: bin/linux/amd64/kube-controller-manager
      os: linux
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: c175c04120b9fa4b0fcce3100a6219d66ce8e95c5603151ddce5320f7fc840ff
        sha512: 2447bee1a6a260899ef211450420457c4d44a57a2279c3a7f289ac43935f5584897adb598864d2eb97844b985f06dcb66d55d25ae2946bf3bd1f92908bb18814
        uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/kubernetes/v1.18.9/bin/linux/amd64/kube-proxy
      description: kube-proxy binary for linux/amd64
      name: bin/linux/amd64/kube-proxy
      os: linux
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: 945a669e3106fd3f2131396f334d2db1c88056570ce8b3a618e77e8a8a92d58f
        sha512: c9e00ac6a3b4e96474e3d89e799a5e82ef9ebf5935f86569c514a6ac086bfa51a4b69c109ac3f500e869167651df6e83c24626a1424b76569ff7efae817f205c
        uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/kubernetes/v1.18.9/bin/linux/amd64/kube-scheduler
      description: kube-scheduler binary for linux/amd64
      name: bin/linux/amd64/kube-scheduler
      os: linux
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: 8d5e27347dbd49ef08f078dc8181750080dbbebd0f0f5e666a9787b11628b57a
        sha512: cde7fd222e82888909a6482c01c0208499e974fe195335705dbbb07f4bc4300337e6f40451658acc9a5bc642f4cb351e41c784d69decabf87d7cb34805092fcf
        uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/kubernetes/v1.18.9/bin/linux/amd64/kubectl
      description: kubectl binary for linux/amd64
      name: bin/linux/amd64/kubectl
      os: linux
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: 97a27c8427b6cbdc0587055db337a85b3aee9bf3a5e6a28fda5431427b7c1a61
        sha512: ce06cb6a7c0604ad331b69e1e5432bab0df87618f6128628466b2f2a244d337a19b547c6b413bc85e6eec2485d4d50e6838fa98f2d6f2d0112a34eaa37ab41be
        uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/kubernetes/v1.18.9/bin/linux/amd64/kubelet
      description: kubelet binary for linux/amd64
      name: bin/linux/amd64/kubelet
      os: linux
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: d959814082972b849aff5623731684b16a0a8c4f55643704b23962693f4c4947
        sha512: e49ebf28ac70cfcbfa9997a93864a261f564f61c8b92fe87f78f8c39d8ff0edb5c0df81553b94fc9bc77531f955deca2674ef63b3e8a7393bf66017270cdfd92
        uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/kubernetes/v1.18.9/bin/windows/amd64/kube-proxy.exe
      description: kube-proxy.exe binary for windows/amd64
      name: bin/windows/amd64/kube-proxy.exe
      os: windows
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: 8bb329508944557a8a6e0bf507700000a51d40828bc4d9c25e25f01b91733398
        sha512: 7189118080f61cfc079db9c54cc81e0ae4ddba44b32e3d097286229139dcd609c53fffe86f054081238c949ed8bc94ecbd38653893a352ce3df71d1770275690
        uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/kubernetes/v1.18.9/bin/windows/amd64/kubeadm.exe
      description: kubeadm.exe binary for windows/amd64
      name: bin/windows/amd64/kubeadm.exe
      os: windows
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: b2ff6f816efb110b63f6fedc09db0b9961d2ac1642160c790974434ae8762eee
        sha512: 541f3cf5e9ce86e010a5ce78da7304d5cb3231e08ee7bdfae0f59c3c46c1046b1143607d660c236273de5fb8333dac5093e1511a594795e383d7676ac07a404e
        uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/kubernetes/v1.18.9/bin/windows/amd64/kubectl.exe
      description: kubectl.exe binary for windows/amd64
      name: bin/windows/amd64/kubectl.exe
      os: windows
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: 002aa632f267d74a74fc07b204301cab6d2af847f65f68d196606c7f242171ce
        sha512: f503a65e27ade9d0e14eafe4abd3f5dca747a1bddba6f2a66205d5581f89d52ea38a9e6a1ab05fc7737cab97aa012cb4cd4c5b6884cff6e3251c9c7f9090b3ca
        uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/kubernetes/v1.18.9/bin/windows/amd64/kubelet.exe
      description: kubelet.exe binary for windows/amd64
      name: bin/windows/amd64/kubelet.exe
      os: windows
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: 5615d73019d30b8a95b6a6ea477143f05cb7e2f2c6b53047e069ac8919ece44a
        sha512: 7181f60cc3eb43c7433841461d8d91a26b089dd4e1df6493a0a8c673423493021d5dc097614c5db5259cacb0a2c2e7f17c352dd6e4ece64ac6ba3a371d71bc98
        uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/kubernetes/v1.18.9/bin/darwin/amd64/kubectl
      description: kubectl binary for darwin/amd64
      name: bin/darwin/amd64/kubectl
      os: darwin
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: 69f8d1f92972b1986b6f4ffa8eaf22eb220924318b3f31b9efa630b39633dbfd
        sha512: a5b0a2ab42a810bd72be29df8fc7a87844c23a4ae22bcd265316550fafb8b1ede2bdeb5c706968481d48ee34228c3ef17a81d7cc72e3bd521c5f29bb76f1b506
        uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/kubernetes/v1.18.9/bin/linux/amd64/kube-apiserver.tar
      description: kube-apiserver linux/amd64 OCI image tar
      name: bin/linux/amd64/kube-apiserver.tar
      os: linux
      type: Archive
    - arch:
      - arm64
      archive:
        sha256: 905948ad21a95ab76484e7b62e97e519b52e790f750cab3bede470c4f1cd6672
        sha512: 7f4583489b1429a46805d28169a25fdab8e4b700f4df06ebb14e45c3a86a8063db7153c334ab46fbbd50c79c57b5f6efc406b21491f92aaefdc0bc50242696e3
        uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/kubernetes/v1.18.9/bin/linux/arm64/kube-apiserver.tar
      description: kube-apiserver linux/arm64 OCI image tar
      name: bin/linux/arm64/kube-apiserver.tar
      os: linux
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: 0c703aa5cd0cc675414c2086986952832362297ac6f8f955aa15d343e5966d48
        sha512: 8a6c9a1e2609b204f0b356364ecb59464e7f6d2a306776a652b11a14843164d5aefcd1682abd9d5a0caa0b535e74a5bb7147a470eb5728d47d5134f05b9e8de2
        uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/kubernetes/v1.18.9/bin/linux/amd64/kube-controller-manager.tar
      description: kube-controller-manager linux/amd64 OCI image tar
      name: bin/linux/amd64/kube-controller-manager.tar
      os: linux
      type: Archive
    - arch:
      - arm64
      archive:
        sha256: d8a357b00cf3e42a5469d8b289f73468b04bb442def96bccb323d3e1a692a645
        sha512: 0ce201e205c2f10d999f8279702dcd415178d2ee1860dd2081a59149d9c4c55e86463be3abc75fe9f21858e173f74e0ac58e5ba2baeb94c9d79143fce1f1c9fc
        uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/kubernetes/v1.18.9/bin/linux/arm64/kube-controller-manager.tar
      description: kube-controller-manager linux/arm64 OCI image tar
      name: bin/linux/arm64/kube-controller-manager.tar
      os: linux
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: 0ec4d3b9b582fbe9d3ad980e44c3c88326c88b04fbe49ac7b90d9b60e6cbf2d4
        sha512: 1ca684a665e7c1cdc103aea09cf8fe1f49cbe4acaaa95e189c14f996a7a6887034e47080c430786cb97f5e92746576c333ebd5176504c761ed2915f645bcff46
        uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/kubernetes/v1.18.9/bin/linux/amd64/kube-scheduler.tar
      description: kube-scheduler linux/amd64 OCI image tar
      name: bin/linux/amd64/kube-scheduler.tar
      os: linux
      type: Archive
    - arch:
      - arm64
      archive:
        sha256: 67890f08f6f51a6459c7bf180655bb33a23dce483c88449b2b8558929a7f69c8
        sha512: a30e28a399fcd74dbd567a79450501abb418ba8ff707639dc0042e7d76bbdbc60e65134cb5161123a7803eaf801f07335db2ba5f5474399ff37ae0880f006c8c
        uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/kubernetes/v1.18.9/bin/linux/arm64/kube-scheduler.tar
      description: kube-scheduler linux/arm64 OCI image tar
      name: bin/linux/arm64/kube-scheduler.tar
      os: linux
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: 1562b62b70e55b996c7804baf796f54dd8f882b1a4641d5e6014e643dd2e1974
        sha512: 09d5b0ec5ee00fec13ec08d7513e0a0073d67d4778e18465f0b11742440bd9f2d94c38232d48a2c4e3109c939076c6aea3cec972fd96482ffbe6d3b71237cd49
        uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/kubernetes/v1.18.9/bin/linux/amd64/kube-proxy.tar
      description: kube-proxy linux/amd64 OCI image tar
      name: bin/linux/amd64/kube-proxy.tar
      os: linux
      type: Archive
    - arch:
      - arm64
      archive:
        sha256: f7e87139d75d30f85acc3022b2c6e25b24ebb174bde68a90a544cd52b3fb25ce
        sha512: f90590aa99269ab0226f5ce476068cab67c13091b0e1847b3cc320df3ddaa6b165525a4c951b3af0ea964e871f49312e0b6a148a513d275e7659a3e28dad06c2
        uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/kubernetes/v1.18.9/bin/linux/arm64/kube-proxy.tar
      description: kube-proxy linux/arm64 OCI image tar
      name: bin/linux/arm64/kube-proxy.tar
      os: linux
      type: Archive
    - archive:
        sha256: 6fdfb339ffb1243774bfce278af5c0858ffda8fb753a1f0d7ab6085750f97d64
        sha512: f6b61f6e22a19d56b0c6469f551afe82732f932c2e610657452a03631047c8038dda75cbfca34e731fe9c143ce4dbf5e532bfaf8a82f57b7aeae079cd35d180a
        uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/kubernetes/v1.18.9/kubernetes-src.tar.gz
      description: Kubernetes source tarball
      name: kubernetes-src.tar.gz
      type: Archive
    gitCommit: 94f372e501c973a7fa9eb40ec9ebd2fe7ca69848
    gitTag: v1.18.9
    name: kubernetes
  - assets:
    - arch:
      - arm64
      archive:
        sha256: ba837b5c2598eb4352add10005879423e8bf4e8628aed16f0c191bf5b19415d4
        sha512: ee7de73a8c83b81aeb420d33a30ccdfccb4fc0b499dd2d62e0f210fa8e1b995510976d4cdafe2299255615c0f6b055dcc53a785d97877e10fbb4f4cd6b15a87e
        uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/aws-iam-authenticator/v0.5.2/aws-iam-authenticator-linux-arm64-v0.5.2.tar.gz
      description: aws-iam-authenticator tarball for linux/arm64
      name: aws-iam-authenticator-linux-arm64-v0.5.2.tar.gz
      os: linux
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: dfdab2eb7958e15922606713fa97ac0644db111b3a72c25e1afe4d3c2314024f
        sha512: 540203884bbff5d9f14868f6603162b464f67619b32d7ccb31e42522e66ec7220330c7dcce489e65bf9429c84c7f75e3aced78e69f2cf2b833aa40e2906223f2
        uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/aws-iam-authenticator/v0.5.2/aws-iam-authenticator-linux-amd64-v0.5.2.tar.gz
      description: aws-iam-authenticator tarball for linux/amd64
      name: aws-iam-authenticator-linux-amd64-v0.5.2.tar.gz
      os: linux
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: 2641f43b9df5fc55560e4273825f0a89325cea0c75633d05f6b312be80c49370
        sha512: b320306cae837144758b1d5b50199b0cb5924601a5b000b07ab13908af0dd6af29e84f6ec608869dec11b73abad57be4363b64163c12ab00b116e5fdd4ec8f7e
        uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/aws-iam-authenticator/v0.5.2/aws-iam-authenticator-windows-amd64-v0.5.2.tar.gz
      description: aws-iam-authenticator tarball for windows/amd64
      name: aws-iam-authenticator-windows-amd64-v0.5.2.tar.gz
      os: windows
      type: Archive
    - arch:
      - amd64
      archive:
        sha256: a61cd130aec128fd8cf992ba8597e8b74e6ee7e72cd7be177e0fa529abe17c16
        sha512: b4fe415af68bfe2f0a1b10d45bfebe62786ee11f223e86d52cf4adecfb7b8363e9b50e4bf3a62bc00d07f058285ea1f08921d93e810b320625a82f1ea7cec173
        uri: https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/aws-iam-authenticator/v0.5.2/aws-iam-authenticator-darwin-amd64-v0.5.2.tar.gz
      description: aws-iam-authenticator tarball for darwin/amd64
      name: aws-iam-authenticator-darwin-amd64-v0.5.2.tar.gz
      os: darwin
      type: Archive
    - arch:
      - amd64
      - arm64
      description: aws-iam-authenticator container image
      image:
        uri: public.ecr.aws/eks-distro/kubernetes-sigs/aws-iam-authenticator:v0.5.2-eks-1-18-1
      name: aws-iam-authenticator-image
      os: linux
      type: Image
    gitTag: v0.5.2
    name: aws-iam-authenticator
  - assets:
    - arch:
      - amd64
      - arm64
      description: node-driver-registrar container image
      image:
        uri: public.ecr.aws/eks-distro/kubernetes-csi/node-driver-registrar:v2.0.1-eks-1-18-1
      name: node-driver-registrar-image
      os: linux
      type: Image
    gitTag: v2.0.1
    name: node-driver-registrar
  - assets:
    - arch:
      - amd64
      - arm64
      description: csi-snapshotter container image
      image:
        uri: public.ecr.aws/eks-distro/kubernetes-csi/external-snapshotter/csi-snapshotter:v3.0.2-eks-1-18-1
      name: csi-snapshotter-image
      os: linux
      type: Image
    - arch:
      - amd64
      - arm64
      description: snapshot-controller container image
      image:
        uri: public.ecr.aws/eks-distro/kubernetes-csi/external-snapshotter/snapshot-controller:v3.0.2-eks-1-18-1
      name: snapshot-controller-image
      os: linux
      type: Image
    - arch:
      - amd64
      - arm64
      description: snapshot-validation-webhook container image
      image:
        uri: public.ecr.aws/eks-distro/kubernetes-csi/external-snapshotter/snapshot-validation-webhook:v3.0.2-eks-1-18-1
      name: snapshot-validation-webhook-image
      os: linux
      type: Image
    gitTag: v3.0.2
    name: external-snapshotter
  date: "2020-12-01T00:05:35Z"
```
