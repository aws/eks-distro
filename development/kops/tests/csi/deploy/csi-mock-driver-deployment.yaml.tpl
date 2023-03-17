# This YAML file contains the deployment of the CSIDriver
# including node-driver-registrar, external-provisioner, external-snapshotter
# external-resizer and mock-driver
#
# This YAML file also includes deployment of the CSIDriver, StorageClass
# VolumeSnapshotClass for the mock driver.

kind: Deployment
apiVersion: apps/v1
metadata:
  name: csi-mockplugin
spec:
  replicas: 1
  selector:
    matchLabels:
      app: csi-mockplugin
  template:
    metadata:
      labels:
        app: csi-mockplugin
    spec:
      serviceAccount: csi-mock
      containers:
        - name: csi-provisioner
          image: {{ .csi_provisioner.repository }}:{{ .csi_provisioner.tag }}
          args:
            - "--csi-address=/csi/csi.sock"
          imagePullPolicy: "IfNotPresent"
          volumeMounts:
            - name: socket-dir
              mountPath: /csi
          # Normally privileged: true is only required for the driver container to perform 
          # the mount operation. However, privileged container is necessary for systems with 
          # SELinux, where non-privileged sidecar containers cannot access unix domain socket
          # created by privileged CSI driver container. The other containers in this file being 
          # granted privileged permission are for the same reason.
          securityContext:
            privileged: true
        - name: node-driver-registrar
          image: {{ .node_driver_registrar.repository }}:{{ .node_driver_registrar.tag }}
          args:
            - --v=5
            - --csi-address=/csi/csi.sock
            - --kubelet-registration-path=/var/lib/kubelet/plugins/io.kubernetes.storage.mock/csi.sock
          env:
            - name: KUBE_NODE_NAME
              valueFrom:
                fieldRef:
                  apiVersion: v1
                  fieldPath: spec.nodeName
          securityContext:
            privileged: true
          volumeMounts:
          - mountPath: /csi
            name: socket-dir
          - mountPath: /registration
            name: registration-dir
        - name: csi-resizer
          image: {{ .csi_resizer.repository }}:{{ .csi_resizer.tag }}
          args:
            - "--v=5"
            - "--csi-address=/csi/csi.sock"
          securityContext:
            privileged: true
          volumeMounts:
          - mountPath: /csi
            name: socket-dir
        - name: csi-attacher
          image: {{ .csi_attacher.repository }}:{{ .csi_attacher.tag }}
          args:
            - "--v=5"
            - "--csi-address=/csi/csi.sock"
          securityContext:
            privileged: true
          volumeMounts:
          - mountPath: /csi
            name: socket-dir
        - name: csi-snapshotter
          image: {{ .csi_snapshotter.repository }}:{{ .csi_snapshotter.tag }}
          args:
            - "--v=5"
            - "--csi-address=/csi/csi.sock"
          volumeMounts:
            - name: socket-dir
              mountPath: /csi
          securityContext:
            privileged: true
        - name: liveness-probe
          args:
          - --csi-address=/csi/csi.sock
          image: {{ .csi_livenessprobe.repository }}:{{ .csi_livenessprobe.tag }}
          resources: {}
          volumeMounts:
          - mountPath: /csi
            name: socket-dir
        - name: mock-driver
          image: registry.k8s.io/sig-storage/mock-driver:v4.1.0
          args:
            - "--attach-limit=50"
            # Required for e2e test log parsing
            - "--v=5"
          env:
            - name: CSI_ENDPOINT
              value: /csi/csi.sock
          # The driver container has to be privileged in order to do mount operation
          securityContext:
            privileged: true
          volumeMounts:
            - name: socket-dir
              mountPath: /csi
            - name: kubelet-pods-dir
              mountPath: /var/lib/kubelet/pods
            - name: kubelet-csi-dir
              mountPath: /var/lib/kubelet/plugins/kubernetes.io/csi
      volumes:
        - name: socket-dir
          hostPath:
            path: /var/lib/kubelet/plugins/io.kubernetes.storage.mock
            type: DirectoryOrCreate
        - name: registration-dir
          hostPath:
            path: /var/lib/kubelet/plugins_registry
            type: Directory
        - name: kubelet-pods-dir
          hostPath:
            path: /var/lib/kubelet/pods
            type: Directory
            # mock driver doesn't make mounts and therefore doesn't need mount propagation.
            # mountPropagation: Bidirectional
        - name: kubelet-csi-dir
          hostPath:
            path: /var/lib/kubelet/plugins/kubernetes.io/csi
            type: DirectoryOrCreate
---
apiVersion: storage.k8s.io/v1
kind: CSIDriver
metadata:
  name: io.kubernetes.storage.mock
spec:
  attachRequired: true
  podInfoOnMount: false

---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: test-csi-mock 
provisioner: io.kubernetes.storage.mock
allowVolumeExpansion: true
parameters:

# Not testing snapshotter
# ---
# apiVersion: snapshot.storage.k8s.io/v1beta1
# kind: VolumeSnapshotClass
# metadata:
#   name: csi-mock-snapclass
# driver: io.kubernetes.storage.mock
# deletionPolicy: Delete
