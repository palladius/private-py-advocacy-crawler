# private-py-advocacy-crawler

An avocado crawler  🥑🕷️ on GCP


## Dashboards

* Data are in BQ:
* PLX Dashboard: `go/ose-volta-dashboard`


## dev

```
$ . .venv/bin/activate
```

## Authewntication

```
$ cd iac/
$ direnv allow # parses the ENV vars
$ ./00-init.sh # sets gcloud for success..
$ gcloud auth login --update-adc
```
