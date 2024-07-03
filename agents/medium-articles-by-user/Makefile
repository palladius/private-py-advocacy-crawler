
run-for-ricc:
	MEDIUM_USER_ID=palladiusbonton LDAP=ricc time ruby main.rb


deploy:
	gcloud functions deploy my_function \
		--runtime ruby32 \
		--trigger-http \
		--entry-point hello \
		--source . \
		--allow-unauthenticated

clean:
	rm -f inputs/*xml inputs/*txt

generate-useful-data:
	# myself
	MEDIUM_USER_ID=palladiusbonton LDAP=ricc ruby main.rb

	# My advocacy team
	LDAP=pvergadia  MEDIUM_USER_ID=pvergadia ruby main.rb
	LDAP=romin MEDIUM_USER_ID=iromin ruby main.rb
	LDAP=deleplace  MEDIUM_USER_ID=val_deleplace ruby main.rb
	LDAP=glaforge  MEDIUM_USER_ID=glaforge ruby main.rb
	LDAP=laupic  MEDIUM_USER_ID=PicardParis ruby main.rb
	LDAP=alexismp  MEDIUM_USER_ID=alexismp ruby main.rb
	LDAP=venema  MEDIUM_USER_ID=wietsevenema ruby main.rb
	LDAP=marccohen  MEDIUM_USER_ID=mco-blog ruby main.rb
	# Extended advocacy team
	# Aja
	LDAP=ajahammerly  MEDIUM_USER_ID=thagomizer ruby main.rb
	# Kaz
	LDAP=kazsato  MEDIUM_USER_ID=kazunori279 ruby main.rb
	# Yoshi
	LDAP=yoshifumi  MEDIUM_USER_ID=ymotongpoo ruby main.rb

	# My other Google friends who might blog about
	LDAP=cstanger  MEDIUM_USER_ID=ch.stanger ruby main.rb

	# Popular people
	MEDIUM_USER_ID=dhh ruby main.rb

	# Google friends - GDEs/ICs
	MEDIUM_USER_ID=gianni.forlastro ruby main.rb

	# Random people - not affiliated to Google
	MEDIUM_USER_ID=hasanaboulhasan ruby main.rb
