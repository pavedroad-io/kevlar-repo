# Install golang and selected go packages
# Install vim-go plugin dependencies

{% set installs = grains.cfg_golang.installs %}
{% if installs and 'golang' in installs %}
  {% set golang_pkg_name = 'go' %}
  {% set golang_snap_install = True %}
  {% set snapd_required = True %}
  {% set snap_path = '/snap/bin/' %}

  {% if grains.docker %}
    {% set golang_snap_install = False %}
  {% elif grains.os_family == 'MacOS' %}
    {% set golang_snap_install = False %}
  {% elif grains.os_family == 'Windows' %}
    {% set golang_snap_install = False %}
  {% endif %}

  {% if golang_snap_install %}
    {% if grains.cfg_golang.golang.version is defined %}
      {% set golang_channel = grains.cfg_golang.golang.version + '/stable' %}
    {% else %}
      {% set golang_channel = 'stable' %}
    {% endif %}
  {% else %}
    {% set snap_path = '' %}
    {% if not grains.os_family == 'Suse' %}
      {% set golang_pkg_name = 'golang' %}
    {% endif %}
  {% endif %}

  {% if golang_snap_install and snapd_required %}
include:
  - snapd
  {% endif %}

golang:
  {% if golang_snap_install %}
    {% if snapd_required %}
  cmd.run:
    - unless:   command -v go
    - require:
      - sls:    snapd
    - unless:   snap list | grep go
    - name:     snap install go --channel {{ golang_channel }} --classic
    {% else %}
  snap.installed:
    - unless:   command -v go
    - name:     {{ golang_pkg_name }}
    - channel:  {{ golang_channel }}
    {% endif %}
  {% else %}
  pkg.installed:
    - unless:   command -v go
    - name:     {{ golang_pkg_name }}
    {% if grains.cfg_golang.golang.version is defined %}
    - version:  {{ grains.cfg_golang.golang.version }}
    {% endif %}
  {% endif %}


  {% load_yaml as go_tools %}
  godep:        github.com/tools/godep
  dlv:          github.com/go-delve/delve/cmd/dlv
  golint:       golang.org/x/lint/golint
  gosec:        github.com/securego/gosec/cmd/gosec
  asmfmt:       github.com/klauspost/asmfmt/cmd/asmfmt
  errcheck:     github.com/kisielk/errcheck
  fillstruct:   github.com/davidrjenni/reftools/cmd/fillstruct
  gocode:       github.com/mdempsky/gocode
  gocode-gomod: github.com/stamblerre/gocode
  godef:        github.com/rogpeppe/godef
  gogetdoc:     github.com/zmb3/gogetdoc
  goimports:    golang.org/x/tools/cmd/goimports
  gopls:        golang.org/x/tools/cmd/gopls
  gometalinter: github.com/alecthomas/gometalinter
  golangci-lint: github.com/golangci/golangci-lint/cmd/golangci-lint
  gomodifytags: github.com/fatih/gomodifytags
  gorename:     golang.org/x/tools/cmd/gorename
  gotags:       github.com/jstemmer/gotags
  guru:         golang.org/x/tools/cmd/guru
  impl:         github.com/josharian/impl
  keyify:       honnef.co/go/tools/cmd/keyify
  motion:       github.com/fatih/motion
  iferr:        github.com/koron/iferr
  {% endload %}

  {% for key in go_tools %}
    {% if key in installs %}
{{ key }}:
  cmd.run:
    - name:     {{ snap_path }}go get {{ go_tools[key] }}
    {% endif %}
  {% endfor %}
{% endif %}

{% if grains.cfg_golang.debug.enable %}
golang-version:
  cmd.run:
    - name:     {{ snap_path }}go version
golang-test:
  file.managed:
    - name:     {{ grains.homedir }}/go/src/hello/hello.go
    - source:   {{ grains.stateroot }}/golang/hello.go
    - user:     {{ grains.username }}
    - makedirs: True
  cmd.run:
    - name: |
                cd $HOME/go/src/hello
                {{ snap_path }}go build
                ./hello
{% endif %}
