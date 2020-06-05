# ruller-sample-feature-flag
A sample project for feature flag management based on customer id and location by IP

# Description

  * **domains**

     * It will control the domain name for each service so that a client can use it in order to distribute its requests between cloud providers
```
rule contents:
...
    "_items": [{
            "_condition": "randomPerc(10, input:customerid)",
            "login": "login.sa-east-1.test.com",
            "analytics": "analytics.sa-east-1.test.com",
        },
        {
            "_condition": "randomPercRange(10, 50, input:customerid)",
            "login": "login.azure.test.com",
            "analytics": "analytics.azure.test.com",
        },
        {
            "login": "login.vpsdime.test.com",
            "analytics": "analytics.vpsdime.test.com",
        }
...
```
     * "aws" will be used for 10% of customers
     * "azure" by 40% of customers
     * "vpsdime" by the remaining of customers
     * The same returning customer will always use the same cloud provider, so that we can track where he is trying to access in case of error reporting
     * We use "flatten" config here, so that even the rule declaration being hierarchical, its results will be flattened, because the client needs to see just a plain view of the results
```
sample results:
{
    "login": "login.vpsdime.test.com",
    "analytics": "analytics.vpsdime.test.com"
}
```
     * see ruller-sample-feature-flag/domains.json for a complete example with regional switching based on user ip address

# How to run this sample

```
git clone http://github.com/flaviostutz/ruller-sample-feature-flag
docker-compose up --build
curl -X POST \
  http://localhost:3000/rules/domains \
  -H 'Content-Type: application/json' \
  -H 'X-Forwarded-For: 177.79.35.49' \
  -H 'cache-control: no-cache' \
  -d '{
	"customerid": "22111"
  }'
```

# More info
  * For more info about supported functions and semantics of ruller-dsl-feature-flag, go to https://github.com/flaviostutz/ruller-dsl-feature-flag/blob/master/README.md#feature-selection-language

