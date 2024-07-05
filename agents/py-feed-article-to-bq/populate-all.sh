
# the ones with metadata file
MEDIUM_USERS=$(ls ../medium-articles-by-user/outputs/medium-latest-articles.*.metadata.json  | sed -e 's/.*medium-latest-articles.//' | sed -e 's/.metadata.json//' )

for MEDIUM_USER in $MEDIUM_USERS ; do
    ./populate-by-medium-user.sh "$MEDIUM_USER" &&
        touch ".populated.$MEDIUM_USER.ok.touch" ||
            touch ".populated.$MEDIUM_USER.error-$?.touch"

done
