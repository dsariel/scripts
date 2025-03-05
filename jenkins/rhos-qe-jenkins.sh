#git clone https://git.openstack.org/openstack-infra/jenkins-job-builder
JJBDIR=/home/dsariel/projects/jenkins-job-builder
pyton -m venv $JJBDIR/.venv
source $JJBDIR/.venv/bin/activate
pushd $JJBDIR
pip install -r test-requirements.txt -e .
popd
# git clone <...>/rhos-qe-jenkins # jenkins jobs repo
cd /home/dsariel/projects/rhos_qe_jenkins
export PYTHONHTTPSVERIFY=0
#export REQUESTS_CA_BUNDLE=./infra/slaves/roles/slave/files/ssl-RH-IT-Root-CA.crt
jenkins-jobs --ignore-cache update jobs/defaults:jobs/DFG/storage/cinder
#--conf jobs/config.ini
#jenkins-jobs --ignore-cache update jobs/infrared/gate-infrared-external-plugins.yaml:jobs/infrared/scm.yaml:jobs/infrared/triggers.yaml:jobs/infrared/jobs-templates.yaml:jobs/defaults/
