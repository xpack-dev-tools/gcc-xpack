---

title: The xPack GNU Compiler Collection releases
permalink: /dev-tools/gcc/releases/

search: exclude
github_editme: false

comments: false
toc: false

date: 2021-05-22 00:27:00 +0300

redirect_to: https://xpack-dev-tools.github.io/gcc-xpack/docs/releases/

---

___
{% for post in site.posts %}{% if post.categories contains "releases" %}{% if post.categories contains "gcc" %}
* [{{ post.title }}]({{ site.baseurl }}{{ post.url }}) [(download)]({{ post.download_url }}){% endif %}{% endif %}{% endfor %}
