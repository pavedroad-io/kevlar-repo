# Install snapd

{% if grains.docker %}
  {% set installs = False %}
{% else %}
  {% set installs = grains.cfg_snapd.installs %}
{% endif %}

# Assuming Debian systems already have snapd installed

{% if installs and 'snapd' in installs %}
  {% set snapd_install_needed = True %}

  {% if grains.os_family == 'Suse' %}
    {% set suse_path = 'https://download.opensuse.org/repositories/system:/snappy/' %}
    {% set suse_repo = suse_path + 'openSUSE_Leap_' + grains.osrelease %}
  {% elif grains.os_family == 'MacOS' %}
    {% set snapd_install_needed = False %}
  {% elif grains.os_family == 'Windows' %}
    {% set snapd_install_needed = False %}
  {% endif %}

  {% if snapd_install_needed %}
snapd:
    {% if grains.os_family == 'Suse' %}
  cmd.run:
    - unless:   command -v snap
    - name: |
                sudo=$(command -v sudo)
                $sudo zypper addrepo --refresh {{ suse_repo }} snappy
                $sudo zypper --gpg-auto-import-keys refresh
                $sudo zypper dup --from snappy
                $sudo zypper install -y snapd
                $sudo systemctl enable --now snapd
    {% else %}
  pkg.installed:
    - unless:   command -v snap
    - name:     snapd
      {% if grains.cfg_snapd.snapd.version is defined %}
    - version:  {{ grains.cfg_snapd.snapd.version }}
      {% endif %}
      {% if grains.os_family == 'RedHat' %}
  cmd.run:
    - name: |
                sudo=$(command -v sudo)
                $sudo ln -s /var/lib/snapd/snap /snap
                $sudo systemctl restart snapd.service
      {% endif %}
    {% endif %}
  {% endif %}

snapd-running:
  cmd.run:
    - name:     until snap version >& /dev/null ; do sleep 1; done
    - timeout:  10

  {% if grains.cfg_snapd.debug.enable %}
snapd-version:
  cmd.run:
    - name:     snap version
  {% endif %}
{% endif %}