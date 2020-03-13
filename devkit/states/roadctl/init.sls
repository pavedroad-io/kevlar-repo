# Install roadctl

{% set installs = grains.cfg_roadctl.installs %}
{% set completion = grains.cfg_roadctl.completion %}

{% if installs and 'roadctl' in installs %}
  {% set roadctl_pkg_name = 'roadctl' %}
  {% set roadctl_binary_install = True %}
  {% set roadctl_path = '/usr/local/bin/' %}
  {% set roadctl_binary = roadctl_path + roadctl_pkg_name %}

  {# Temporary until github binary runs on MacOS #}
  {% if grains.os_family == 'MacOS' %}
    {% set roadctl_binary_install = False %}
  {% endif %}

  {% if roadctl_binary_install %}
    {% set roadctl_prefix = 'https://github.com/pavedroad-io/roadctl/releases/latest/download/' %}
    {% if grains.cfg_roadctl.roadctl.version is defined and
      grains.cfg_roadctl.roadctl.version != 'latest' %}
      {% set roadctl_version = grains.cfg_roadctl.roadctl.version %}
    {% else %}
      {% set roadctl_version = 'v0.5.2alpha' %}
    {% endif %}
    {% if grains.os_family == 'MacOS' %}
      {% set roadctl_file = '/roadctl-darwin-amd64' %}
    {% else %}
      {% set roadctl_file = '/roadctl-linux-amd64' %}
    {% endif %}
    {% set roadctl_url = roadctl_prefix + roadctl_version + roadctl_file %}
  {% else %}
    {% set roadctl_url = 'https://github.com/pavedroad-io/roadctl.git' %}
    {% set roadctl_src = grains.homedir + '/go/src' %}
  {% endif %}

  {% if not roadctl_binary_install %}
{# Get development tools to run make #}
include:
  - golang
  - graphviz
    {% if grains.os_family == 'Debian' %}
  - debian
    {% elif grains.os_family == 'RedHat' %}
  - redhat
    {% elif grains.os_family == 'MacOS' %}
  - macos
    {% endif %}
  {% endif %}

roadctl:
  {% if roadctl_binary_install %}
  file.managed:
    - name:        {{ roadctl_path }}/{{ roadctl_pkg_name }}
    - source:      {{ roadctl_url }}
    - makedirs:    True
    - skip_verify: True
    - mode:        755
    - replace:     False
  {% else %}
    {% if grains.os_family == 'Suse' %}
  {# roadctl make file uses which, missing in bare Suse #}
  pkg.installed:
    - unless:   command -v which
    - name:     which
    {% endif %}
  cmd.run:
    - name:     rm -rf {{ roadctl_src }}/{{ roadctl_pkg_name }}
  git.latest:
    - name:        {{ roadctl_url }}
    - rev:         master
    - target:      {{ roadctl_src }}/{{ roadctl_pkg_name }}
    - force_clone: True
    - force_fetch: True
    - force_reset: remote-changes
roadctl-build:
  cmd.run:
    - require:
      - git:    roadctl
    - cwd:      {{ roadctl_src }}/{{ roadctl_pkg_name }}
    {% if grains.os_family in ('RedHat', 'Suse') %}
    - runas:    {{ grains.realuser }}
      {% if not grains.docker %}
    - group:    {{ grains.realgroup }}
      {% endif %}
    {% endif %}
    - umask:    022
    - name:     |
                . {{grains.homedir}}/.pr_go_env
                make compile
  file.managed:
    - name:        {{ roadctl_binary }}
    - source:      {{ roadctl_src }}/{{ roadctl_pkg_name }}/{{ roadctl_pkg_name }}
    - makedirs:    True
    - skip_verify: True
    - mode:        755
  {% endif %}

  {# roadctl only seems to support bash completion #}
  {% if completion %}
    {% if 'bash' in completion %}
      {% set bash_comp_file = pillar.directories.completions.bash + '/roadctl' %}
roadctl-bash-completion:
  cmd.run:
    - name:     |
                mkdir -p {{ pillar.directories.completions.bash }}
                {{ roadctl_binary }} completion bash > {{ bash_comp_file }}
    - unless:   test -e {{ bash_comp_file }}
    - onlyif:   test -x {{ roadctl_binary }}
    {% endif %}
    {% if 'zsh' in completion %}
      {% set zsh_comp_file = pillar.directories.completions.zsh + '/_roadctl' %}
roadctl-zsh-completion:
  cmd.run:
    - name:     |
                mkdir -p {{ pillar.directories.completions.zsh }}
                {{ roadctl_binary }} completion zsh > {{ zsh_comp_file }}
    - unless:   test -e {{ zsh_comp_file }}
    - onlyif:   test -x {{ roadctl_binary }}
    {% endif %}
  {% endif %}

  {% if grains.cfg_roadctl.debug.enable %}
roadctl-version:
  cmd.run:
    - name:     {{ roadctl_binary }} version
  {% endif %}
{% endif %}
