# Install multipass

{% set installs = grains.cfg_multipass.installs %}
{% set completion = grains.cfg_multipass.completion %}

{% if installs and 'multipass' in installs %}
  {% set multipass_pkg_name = 'multipass' %}
  {% set multipass_supported = True %}
  {% set multipass_snap_install = True %}
  {% set multipass_path = '/snap/bin/' %}
  {% set snapd_required = True %}

  {% if grains.docker %}
    {% set multipass_supported = False %}
  {% elif grains.os_family == 'MacOS' %}
    {% set multipass_snap_install = False %}
    {% set multipass_path = '/usr/local/bin/' %}
  {% elif grains.os_family == 'Windows' %}
    {% set multipass_snap_install = False %}
  {% endif %}

  {% if multipass_supported and multipass_snap_install and snapd_required or completion and 'bash' in completion %}
include:
    {% if multipass_supported and multipass_snap_install and snapd_required %}
  - snapd
    {% endif %}
    {% if completion and 'bash' in completion %}
  - bash
    {% endif %}
  {% endif %}

  {% if multipass_supported %}
multipass:
    {% if grains.os_family == 'MacOS' %}
  cmd.run:
    - unless:   command -v multipass
    - name:     brew cask install multipass
# The following worked for casks previously
#   pkg.installed:
#     - name:     caskroom/casks/multipass
# but now salt produces this error:
#   Failure while executing; git clone https://github.com/caskroom/homebrew-casks
# due to homebrew cask project moving to github.com/Homebrew/homebrew-cask
# searches for casks and caskroom in Homebrew project return nada
    {% elif snapd_required %}
  cmd.run:
    - require:
      - sls:    snapd
    - unless:   snap list | grep multipass
      {# SELinux is blocking multipass install hook on Centos #}
      {# TODO: remove this when no longer needed #}
      {% if grains.os_family == 'RedHat' %}
    - name:     |
                sudo setenforce 0
                snap install --beta multipass --classic
                sudo setenforce 1
      {% else %}
    - name:     snap install --beta multipass --classic
      {% endif %}
    {% else %}
  pkg.installed:
    - unless:   command -v multipass
    - name:     multipass
      {% if grains.cfg_multipass.multipass.version is defined %}
    - version:  {{ grains.cfg_multipass.multipass.version }}
      {% endif %}
    {% endif %}

    {% if completion and 'bash' in completion %}
      {% set multipass_prefix = 'https://raw.githubusercontent.com/CanonicalLtd' %}
      {% set multipass_content = '/multipass/master/completions/bash/multipass' %}
      {% set multipass_comp_url = multipass_prefix + multipass_content %}
      {# brew cask install does not install completion #}
      {% if grains.os_family == 'MacOS' %}
        {% set bash_comp_dir = '/usr/local/etc/bash_completion.d' %}
      {% else %}
        {% set bash_comp_dir = '/usr/share/bash-completion/completions' %}
      {% endif %}

multipass-bash-completion:
  file.managed:
    - name:     {{ bash_comp_dir }}/multipass
    - source:   {{ multipass_comp_url }}
    - makedirs: True
    - skip_verify: True
    - replace:  False
    - require:
      - sls:    bash
    {% endif %}

    {% if grains.cfg_multipass.debug.enable %}
multipass-version:
  cmd.run:
    - name:     {{ multipass_path }}multipass version
    {% endif %}
  {% endif %}
{% endif %}
