rm -rf /tmp/home-ci &&  home-ci run -v 3 -c $PWD/../home-ci/examples/ktbx.yaml -b $(git branch --show-current) 
