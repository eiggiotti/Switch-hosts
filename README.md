Switch-hosts
============

Allow to switch between different environments in /etc/hosts

Requirements
============

Your /etc/hosts file must be formatted following this pattern :

```
# RECETTE
XXX.XXX.XXX.XXX www.foo.com
XXX.XXX.XXX.XXX www.bar.com

# Other hosts
XXX.XXX.XXX.XXX www.baz.com

# LOCAL
#XXX.XXX.XXX.XXX www.foo.com
#XXX.XXX.XXX.XXX www.bar.com
```

The script will switch to the specified environment.
Example (to switch to "integ") :

```
switch_hosts -i
```

To list the available options :

```
switch_hosts -h
```
