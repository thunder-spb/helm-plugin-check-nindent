# helm-plugin-check-nindent
Simple plugin for Helm to check if the number of whitespaces equals defined nindent

## Install
Just run this:

```bash
$ helm plugin add https://github.com/thunder-spb/helm-plugin-check-nindent.git
```

## Usage
All you need is to provide Helm Chart's folder:
```bash
$ helm check-nindent mychart
```
