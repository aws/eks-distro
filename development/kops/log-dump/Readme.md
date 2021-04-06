# log-dump.sh

This [script](https://github.com/kubernetes/test-infra/blob/master/logexporter/cluster/log-dump.sh) 
comes from the upstream [kubernetes/test-infra](https://github.com/kubernetes/test-infra) repo.

It is copied here to be used during the e2e test runs to gather logs
from the created kOps clusters.  Modifications to the script are kept to a minimal
to allow for easy updating from upstream if ever necessary.  If changes are made, outside
of sync-ing from upstream, please document them here. The script is unmodified except for the following:

* the non-inclusive term `master` has been replaced with `control-plane`
   * sed -i "s/master/control_plane/g" log-dump.sh
   * sed -i "s/MASTER/CONTROL_PLANE/g" log-dump.sh 
   * sed -i "s/Master/Control_Plane/g" log-dump.sh 
   * Note: there are two inconsequential changes made by the above sed commands that actually should not be changed.
     A comment with a github url in it and a file name, which is not create by kops and therefore 
     does not affect the intent of how we are using the script.