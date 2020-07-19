# Install base packages - only firefox as base browser for now

{% set installs = grains.cfg_base.installs %}

{# Do not install firefox in docker container #}
{% if installs and 'firefox' in installs and not grains.docker %}
  {% set firefox_bin_name = 'firefox' %}
  {% set firefox_pkg_name = 'firefox' %}
  {% set firefox_path = '/usr/bin' %}
  {% set firefox_repo_disable = False %}

  {% if grains.os_family == 'Suse' %}
    {% set firefox_pkg_name = 'MozillaFirefox' %}
  {% endif %}

  {% if grains.cfg_base.firefox.version is defined and
    grains.cfg_base.firefox.version != 'latest' %}
    {% set firefox_version = grains.cfg_base.firefox.version %}
  {% else %}
    {% set firefox_version = 'latest' %}
  {% endif %}

  {# Workaround to disable/re-enable repo that causes salt install to fail #}
  {% if grains.os_family == 'Suse' and grains.osfullname == 'Leap' and
    grains.osrelease == '15.1' %}
    {% set firefox_repo_disable = True %}
    {% set firefox_repo_name = 'openSUSE-Leap-15.1-Update' %}
  {% endif %}

  {# Cask install required on MacOS #}
  {% if grains.os_family == 'MacOS' %}
firefox-cask:
  cmd.run:
    - unless:   test -d /Applications/Firefox.app
    - name:     brew cask install firefox
  {% else %}
    {% if firefox_repo_disable %}
repo-disable:
  pkgrepo.managed:
    - name:     {{ firefox_repo_name }}
    - enabled:  False
    {% endif %}
firefox-package:
  pkg.installed:
    - unless:   command -v {{ firefox_bin_name }}
    - name:     {{ firefox_pkg_name }}
    - version:  {{ firefox_version }}
    {% if firefox_repo_disable %}
repo-re-enable:
  pkgrepo.managed:
    - name:     {{ firefox_repo_name }}
    - enabled:  True
    {% endif %}
  {% endif %}

  {% if grains.cfg_base.firefox.debug.enable %}
firefox-version:
  cmd.run:
    - name:     {{ firefox_path }}/{{ firefox_bin_name }} --version
  {% endif %}
{% endif %}
