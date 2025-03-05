infrared plugin add "https://review.gerrithub.io/rhos-infra/patch-components"
cd $WORKSPACE/infrared/plugins/patch-components
git fetch https://review.gerrithub.io/rhos-infra/patch-components refs/changes/71/375871/6 && git cherry-pick FETCH_HEAD
cd -
infrared patch-components --component-name glance --component-version 12
