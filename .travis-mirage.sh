# If a fork of these scripts is specified, use that GitHub user instead
fork_user=${FORK_USER:-ocaml}

# If a branch of these scripts is specified, use that branch instead of 'master'
fork_branch=${FORK_BRANCH:-master}

### Bootstrap

set -uex

get() {
  wget https://raw.githubusercontent.com/${fork_user}/ocaml-ci-scripts/${fork_branch}/$@
}

TMP_BUILD=$(mktemp -d)
cd ${TMP_BUILD}

get .travis-ocaml.sh
get src/yorick/yorick.mli
get src/yorick/yorick.ml
get src/travis_mirage.ml

sh .travis-ocaml.sh
export OPAMYES=1
eval $(opam config env)

# This could be removed with some OPAM variable plumbing into build commands
opam install ocamlfind
ocamlc.opt yorick.mli
ocamlfind ocamlc -c yorick.ml
ocamlfind ocamlc -o travis-mirage -package unix -linkpkg yorick.cmo travis_mirage.ml
cd -

${TMP_BUILD}/travis-mirage
