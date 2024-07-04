
install:
	pip install -r requirements.txt




test-riccardo:
	# ensure called with virtualenv :)
	.venv/bin/python3 main.py \
		--metadata "inputs/medium-latest-articles.palladiusbonton.metadata.json" \
		--articles "inputs/medium-latest-articles.palladiusbonton.txt.cleaned.json"

populate-all-devrellers:
	./populate-all.sh

populate-some-devrellers:
	./populate-by-medium-user.sh glaforge
	./populate-by-medium-user.sh rsamborski
	./populate-by-medium-user.sh palladiusbonton
	./populate-by-medium-user.sh iromin

problematics:
	./populate-by-medium-user.sh val_deleplace
	./populate-by-medium-user.sh wietsevenema

auth:
	gcloud auth login
	gcloud auth application-default login


bq-show-tables:
	bq --project_id ose-volta-dev ls ose_volta_insights

bq-query-how-many-articles:
	cat articles_count.bq.sql | bq query --use_legacy_sql=false


# medium_articles_data
