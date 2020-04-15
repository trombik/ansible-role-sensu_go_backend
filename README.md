# trombik.`sensu_go_backend`

[![Build Status](https://travis-ci.com/trombik/ansible-role-sensu_go_backend.svg?branch=master)](https://travis-ci.com/trombik/ansible-role-sensu_go_backend)

`ansible` role for `sensu-go` version of `sensu-backend`.

# Requirements

None

# Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `sensu_go_backend_user` | user of `sensu-backend` | `{{ __sensu_go_backend_user }}` |
| `sensu_go_backend_group` | group of `sensu-backend` | `{{ __sensu_go_backend_group }}` |
| `sensu_go_backend_package` | package name of `sensu-backend` | `{{ __sensu_go_backend_package }}` |
| `sensu_go_backend_extra_packages` | list of extra packages to install | `{{ __sensu_go_backend_extra_packages }}` |
| `sensu_go_backend_log_dir` | path to log directory | `/var/log/sensu` |
| `sensu_go_backend_state_dir` | path to `state-dir` | `{{ __sensu_go_backend_state_dir }}` |
| `sensu_go_backend_cache_dir` | path of `cache-dir` | `{{ __sensu_go_backend_cache_dir }}` |
| `sensu_go_backend_service` | service name of `sensu-backend` | `{{ __sensu_go_backend_service }}` |
| `sensu_go_backend_conf_dir` | path to base directory of `sensu_go_backend_conf_file` | `{{ __sensu_go_backend_conf_dir }}` |
| `sensu_go_backend_conf_file` | path to `sensu-backend.yml` | `{{ sensu_go_backend_conf_dir }}/sensu-backend.yml` |
| `sensu_go_backend_config` | content of `sensu-backend.yml` | `""` |
| `sensu_go_backend_flags` | see below | `""` |
| `sensu_go_backend_admin_account` | name of admin account | `""` |
| `sensu_go_backend_admin_password` | password of admin account | `""` |

## `sensu_go_backend_flags`

This variable is used to configure startup options for the service.

### FreeBSD

`sensu_go_backend_flags` is the content of `/etc/rc.conf.d/sensu_backend`.

## Debian

| Variable | Default |
|----------|---------|
| `__sensu_go_backend_user` | `sensu` |
| `__sensu_go_backend_group` | `sensu` |
| `__sensu_go_backend_package` | `sensu-go-backend` |
| `__sensu_go_backend_extra_packages` | `["sensu-go-cli"]` |
| `__sensu_go_backend_state_dir` | `/var/lib/sensu/sensu-backend` |
| `__sensu_go_backend_cache_dir` | `/var/cache/sensu/sensu-backend` |
| `__sensu_go_backend_service` | `sensu-backend` |
| `__sensu_go_backend_conf_dir` | `/etc/sensu` |
| `__sensu_go_backend_conf_file` | `{{ __sensu_go_backend_conf_dir }}/backend.yml` |

## FreeBSD

| Variable | Default |
|----------|---------|
| `__sensu_go_backend_user` | `sensu` |
| `__sensu_go_backend_group` | `sensu` |
| `__sensu_go_backend_package` | `sysutils/sensu-go` |
| `__sensu_go_backend_extra_packages` | `[]` |
| `__sensu_go_backend_state_dir` | `/var/db/sensu/sensu-backend` |
| `__sensu_go_backend_cache_dir` | `/var/cache/sensu/sensu-backend` |
| `__sensu_go_backend_service` | `sensu-backend` |
| `__sensu_go_backend_conf_dir` | `/usr/local/etc` |
| `__sensu_go_backend_conf_file` | `{{ __sensu_go_backend_conf_dir }}/sensu-backend.yml` |

# Dependencies

None

# Example Playbook

```yaml
---
- hosts: localhost
  roles:
    - role: trombik.freebsd_pkg_repo
      when: ansible_os_family == 'FreeBSD'
    - role: trombik.apt_repo
      when: ansible_os_family == 'Debian'
    - role: ansible-role-sensu_go_backend
  vars:
    sensu_go_backend_admin_account: admin
    sensu_go_backend_admin_password: P@ssw0rd!
    sensu_go_backend_config:
      state-dir: "{{ sensu_go_backend_state_dir }}"
      cache-dir: "{{ sensu_go_backend_cache_dir }}"
      log-level: debug
      agent-host: "[::]"
      api-listen-address: "[::]:8080"
      dashboard-host: "[::]"
      dashboard-port: 3000

    os_sensu_go_backend_flags:
      FreeBSD: ""
      Debian: ""
    sensu_go_backend_flags: "{{ os_sensu_go_backend_flags[ansible_os_family] }}"
    freebsd_pkg_repo:
      # disable the default package repository
      FreeBSD:
        enabled: "false"
        state: present
      # enable my own package repository, where the latest package is
      # available
      FreeBSD_devel:
        enabled: "true"
        state: present
        url: "http://pkg.i.trombik.org/{{ ansible_distribution_version | regex_replace('\\.', '') }}{{ansible_architecture}}-master-default/"
        mirror_type: http
        signature_type: none
        priority: 100

    # see https://packagecloud.io/install/repositories/sensu/stable/script.deb.sh
    apt_repo_keys_to_add:
      - https://packagecloud.io/sensu/stable/gpgkey
    apt_repo_to_add:
      - deb https://packagecloud.io/sensu/stable/ubuntu/ bionic main
    apt_repo_enable_apt_transport_https: True
```

# License

```
Copyright (c) 2020 Tomoyuki Sakurai <y@trombik.org>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
```

# Author Information

Tomoyuki Sakurai <y@trombik.org>

This README was created by [qansible](https://github.com/trombik/qansible)
