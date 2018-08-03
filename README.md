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
* Bailador & REST:
  * Axioms of Web Architecture: https://www.w3.org/DesignIssues/Axioms.html
  * Bailador
  * Main Page: https://github.com/Bailador/Bailador
  * Docs: https://github.com/Bailador/Bailador/tree/dev/doc
  * Examples: https://github.com/Bailador/Bailador/tree/dev/examples
  * HTTP Response: https://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
  * Please Do Not Patch Like an Idiot: https://williamdurand.fr/2014/02/14/please-do-not-patch-like-an-idiot/
  *  REST API Design Rulebook by Mark Masse Published by O'Reilly Media, Inc., 2011
  * RESTful API Design Tips from Experience: https://medium.com/studioarmix/learn-restful-api-design-ideals-c5ec915a430f
  * Roy Thomas Fiedling's 2000 Ph.D. dissertation "Architectural Styles and the Design of Network-based Software Architectures": https://www.ics.uci.edu/~fielding/pubs/dissertation/top.htm
* MVC
  * https://medium.freecodecamp.org/simplified-explanation-to-mvc-5d307796df30
  * https://developer.mozilla.org/en-US/docs/Web/Apps/Fundamentals/Modern_web_app_architecture/MVC_architecture

  