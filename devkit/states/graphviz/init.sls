# Install graphviz

{% set installs = grains.cfg_graphviz.installs %}

{% if installs and 'graphviz' in installs %}
graphviz:
  pkg.installed:
    - unless:   command -v graphviz
    - name:     graphviz
  {% if grains.cfg_graphviz.graphviz.version is defined %}
    - version:  {{ grains.cfg_graphviz.graphviz.version }}
  {% endif %}
{% endif %}
