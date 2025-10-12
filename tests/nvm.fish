@test "nvm install latest major.minor.patch" (
  nvm install latest >/dev/null 2>&1
  nvm current
) = (nvm list-remote | string match --regex -- "v\d+\.\d+\.\d+")[-1]

@test "nvm install latest minor.patch" (
  nvm install 5 >/dev/null 2>&1
  nvm current
) = v5.12.0

@test "nvm install latest patch" (
  nvm install v5.11 >/dev/null 2>&1
  nvm current
) = v5.11.1

@test ".nvmrc" (
  echo 8.17.0 >.nvmrc
  mkdir -p foo/bar/baz && cd foo/bar/baz
  nvm install >/dev/null 2>&1
  nvm current
) = v8.17.0

@test "nvm install with nvm_enable_corepack" (
  set --global nvm_enable_corepack 1
  nvm install latest >/dev/null 2>&1
  command --search --quiet corepack
  set --erase nvm_enable_corepack
  echo $status
) = 0
