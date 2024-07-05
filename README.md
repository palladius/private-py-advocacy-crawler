# private-py-advocacy-crawler

An avocado crawler  🥑🕷️ on GCP


## Dashboards

* Data are in BQ: https://pantheon.corp.google.com/welcome?project=ose-volta-dev
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

Trix populator: `trix-populator@ose-volta-dev.iam.gserviceaccount.com`
* Key checked in (can only write on one Trix)
