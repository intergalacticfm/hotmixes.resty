To test: modify docker-compose-local.yml to your own local music dir

# build and run container

docker-compose -f docker-compose-local.yml up --build

# access container

http://localhost:8080

# Validation

Check:
- HTML https://validator.w3.org/nu/?doc=https%3A%2F%2Fhotmixes.net
- CSS https://jigsaw.w3.org/css-validator/validator?uri=https%3A%2F%2Fhotmixes.net
- Links https://validator.w3.org/checklink?uri=https%3A%2F%2Fhotmixes.net
- i18n https://validator.w3.org/i18n-checker/check?uri=https%3A%2F%2Fhotmixes.net
- RSS https://validator.w3.org/feed/check.cgi?url=https%3A%2F%2Fhotmixes.net%2Flatest.xml
- unified https://validator.w3.org/unicorn/check?ucn_uri=https%3A%2F%2Fhotmixes.net&ucn_task=conformance
