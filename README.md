# Demo LDES client

This demo consists of an Linked Data Interactions (LDIO) container with an LDES client, and a Virtuoso triple store as database.

## Startup

```
docker-compose up -d
```

## Exit

```
docker-compose down -v
```

Optionally, remove the `data/db` folder to have a clean database again on next startup.

## LDIO Configuration

In the `application.yml` file, you can configure the LDIO container:

* which LDESs to consume
* transform or filter the incoming data with SPARQL Construct

When you change the configuration, you must stop and start the LDIO container* using following command:

```
docker-compose down ldio
docker-compose up ldio -d
```
* in later version of LDIO, you can dynamically update the configuration using the API

## SPARQL queries

Go to `http://localhost:8890`, then to `SPARQL endpoint` to reach the SPARQL editor.

### Discover which types are used

```
SELECT distinct ?type
WHERE {
    GRAPH <http://mu.semte.ch/application> {
        ?s a ?type .
    }
}
```

### Discover which predicates are used on a certain type

```
SELECT distinct ?p
WHERE {
    GRAPH <http://mu.semte.ch/application> {
        ?s a ?type .

        ?s ?p ?o .

        VALUES ?type { <http://www.w3.org/ns/sosa/Observation> }
    }
}
```

### Get 100 instances of a type

```
SELECT ?s
WHERE {
    GRAPH <http://mu.semte.ch/application> {
        ?s a ?type .

        VALUES ?type { <http://www.w3.org/ns/sosa/Observation> }
    }
}
LIMIT 100
```

### Show how an instance looks

Pro-tip: play with "Result format" to have different responses, for example "Turtle (beautified - browser oriented)", "JSON-LD (with context)"

```
DESCRIBE <https://data.imjv.omgeving.vlaanderen.be/id/observatie/00069475000114/1-1-4/geleideemissies/136815/obs/chemische_stof/pm2.5/2022/2025-11-01T09:36:52.22Z>
```

### Top 10 most polluting emission points

Relevant for LDES "imjv_emissies_lucht"

```
PREFIX sosa: <http://www.w3.org/ns/sosa/>
PREFIX schema: <https://schema.org/>
PREFIX wk: <https://data.vlaanderen.be/ns/waterkwaliteit#>

SELECT ?emissiepunt (SUM(?value) AS ?totaleEmissie)
WHERE {
  ?emissie a wk:Emissie ;
           wk:uitgestotenDoor ?emissiepunt ;
           sosa:hasResult ?result .

  ?result schema:value ?value .
}
GROUP BY ?emissiepunt
ORDER BY DESC(?totaleEmissie)
LIMIT 10
```

### Geospatial search within range

Relevant for the Westtoer LDES with touristic attractions:

```
PREFIX geosparql: <http://www.opengis.net/ont/geosparql#>
PREFIX locn: <http://www.w3.org/ns/locn#>
PREFIX bif: <http://www.openlinksw.com/schemas/bif#>

SELECT ?s ?geom ?dist
WHERE {
  ?s locn:geometry ?g .
  ?g geosparql:asWKT ?geom .

  BIND (
    bif:st_distance(
      bif:st_geomfromtext("POINT(2.620327 51.10934)"),
      ?geom
    ) AS ?dist
  )

  FILTER (?dist < 0.01)
}
ORDER BY ?dist
```

### Try Comunica

* Open `https://query.comunica.dev/`
* Add your data source: `http://localhost:8890/sparql`
* Add your SPARQL query
* Execute query