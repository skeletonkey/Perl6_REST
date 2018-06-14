# REST/Perl 6/BAILADOR
Phoenix Perl Monger's June 2018 Presentation

Implementing a REST interface using Perl 6 and Bailador

# Docker
Build Image in this repo:
```
docker build --rm=false -t perl6_rest .
```

Run it as a daemon:
```
docker run -d --rm               \
  --name my_perl6_rest           \
  -p 3123:3123                   \
  -v $(pwd)/code:/code           \
  -v $(pwd)/mysql:/var/lib/mysql \
  perl6_rest
```

# End Points
* Healthcheck: GET http://0.0.0.0:3123/healthcheck
* Home Page: GET http://0.0.0.0:3123
* See All Users: GET http://0.0.0.0:3123/users
* See Specific Users: GET http://0.0.0.0:3123/users/8894aff2-6fd1-11e8-aecd-0242ac110002
* Create User: POST http://0.0.0.0:3123/users

# Resources
* Bailador
  * Main Page: https://github.com/Bailador/Bailador
  * Docs: https://github.com/Bailador/Bailador/tree/dev/doc
  * Examples: https://github.com/Bailador/Bailador/tree/dev/examples