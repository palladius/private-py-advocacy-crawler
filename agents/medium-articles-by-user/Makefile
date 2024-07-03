
run-for-ricc:
	MEDIUM_USER_ID=palladiusbonton ruby main.rb


deploy:
	gcloud functions deploy my_function \
		--runtime ruby32 \
		--trigger-http \
		--entry-point hello \
		--source . \
		--allow-unauthenticated


generate-useful-data: clean-empty-files
	# myself
	MEDIUM_USER_ID=palladiusbonton ruby main.rb

	# My advocacy team
	MEDIUM_USER_ID=pvergadia ruby main.rb
	MEDIUM_USER_ID=iromin ruby main.rb
	MEDIUM_USER_ID=val_deleplace ruby main.rb
	MEDIUM_USER_ID=glaforge ruby main.rb
	MEDIUM_USER_ID=PicardParis ruby main.rb
	MEDIUM_USER_ID=alexismp ruby main.rb
	MEDIUM_USER_ID=wietsevenema ruby main.rb
	MEDIUM_USER_ID=mco-blog ruby main.rb
	# Extended advocacy team
	# Aja
	MEDIUM_USER_ID=thagomizer ruby main.rb
	# Kaz
	MEDIUM_USER_ID=kazunori279 ruby main.rb
	# Yoshi
	MEDIUM_USER_ID=ymotongpoo ruby main.rb



	# My other Google friends who might blog about
	MEDIUM_USER_ID=ch.stanger ruby main.rb

	# Popular people
	MEDIUM_USER_ID=dhh ruby main.rb

	# Google friends - GDEs/ICs
	MEDIUM_USER_ID=gianni.forlastro ruby main.rb
