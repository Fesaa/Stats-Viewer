The StatsBel API has some issues with returning 500 NPE a lot, for this I've made an agresive cache wrapper around it in Proxy. 
You may start it with
```bash
go run .
```
I'd try opening http://localhost:8080/views in your browser or postman,
and restarting the proxy until it returns the json. Instead of the of the error. 

If you wish to deploy the iOS application to your phone, you'll have to change the address it tries getting the data from.
You may do so in `Stats Viewer/Services/StatbelService.swift#5-6`

# Points

- De app maakt gebruik van een webservice om gegevens op te halen.
    - Yes the Statbel API
- De app is opgebouwd volgens het MVVM-patroon (Model-View-ViewModel)
    - Yes, somewhat. The service returns Models.
- Fallback Mechanisme voor offline gebruik: Specificeer hoe de app zich gedraagt
wanneer de gebruiker plots geen internetverbinding meer heeft. Gebruik bijvoor-
beeld een fallback cache-strategie waarbij de laatste succesvolle netwerkrespons lokaal wordt opgeslagen en getoond, met een melding aan de gebruiker dat de
app in offline-modus werkt.
    - Yes, all responses from Statbel are cached for at least one day by the application. If you're offline, the response may be kept for a longer time
- De app maakt gebruik van de locatie van de gebruiker.
    - Possibly? The Map visualisaiton, isn't working very well, and I didn't have the time to resolve all its issues. So, I don't think the location works nicely. But it tries?
- De applicatie slaat data lokaal op in een lokale database.
    - It uses files as cache I suppose? Not sure if this counts.
- De app bevat meerdere schermen en mogelijkheid tot gebruikersinvoer.
    - Yes, both the main screen (filtering) and the view screen (setting up visualisaitons) have user input
- De gebruiker kan zien wanneer de lokaal opgeslagen data voor het laatst werd
bijgewerkt. Standaard zal de applicatie de informatie tonen die lokaal opgeslagen
werd.
    - Yes, if there is no cached response. The web service will be contacted.
- De gebruiker kan de gegevens in de lokale databank laten vernieuwen door de
webservice opnieuw aan te spreken. Optioneel kan je een regelmatige vernieuwing
van de data voorzien. Afhankelijk van de toepassing kan dit bv iedere uur, iedere
dag, ...).
    - Yes, the settings screen allows the user to manage all cached items
- De gegevens zijn toegankelijk voor de gebruiker via de app en worden gevisuali-
seerd. Je bent vrij om het type visualisatie te kiezen. Tot de mogelijkheden behoren
gebruik maken van MapKit of/en een externe library.
    - Charts, and MapKit were used.
- De app maakt gebruik van een externe library.
    - https://github.com/apple/swift-log was used for logging
