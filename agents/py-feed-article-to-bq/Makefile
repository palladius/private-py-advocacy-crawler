
install:
	pip install -r requirements.txt




test-riccardo:
	# ensure called with virtualenv :)
	.venv/bin/python3 main.py \
		"inputs/medium-latest-articles.palladiusbonton.metadata.json" \
		"inputs/medium-latest-articles.palladiusbonton.txt.cleaned.json"

auth:
	gcloud auth login
	gcloud auth application-default login


bq-show-tables:
	bq --project_id ose-volta-dev ls ose_volta_insights

bq-query-how-many-articles:
	cat articles_count.bq.sql | bq query --use_legacy_sql=false


# medium_articles_data
