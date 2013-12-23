cd _assets

aspax                     \
  -s aspax-sources        \
  -d ../assets            \
  -p /assets/             \
  -o ../_data/aspax.yml   \
  pack                    \

cd ..

git add .
git commit -m "autodeploy"
git push
