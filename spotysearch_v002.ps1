
# Pad naar het ASCII-art tekstbestand
$bestandspad = "C:\__SCRIPTS\spotify_ascii.txt.txt"

# Lees de inhoud van het bestand en toon het in groene tekst
$asciiArt = Get-Content -path $bestandspad -raw -encoding utf8
Write-Host $asciiArt 

# Spotify API instellen
# Voer hier je eigen Client ID en Client Secret in van Spotify Developer nadat je een web app hebt aangemaakt (https://developer.spotify.com/dashboard)
$clientId = ""
$clientSecret = ""

# De URL voor het verkrijgen van een API-token
$tokenUrl = "https://accounts.spotify.com/api/token"

# De headers voor authenticatie (Spotify gebruikt Base64-encoded clientgegevens)
$headers = @{"Authorization" = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$clientId`:$clientSecret"))}

# De body van het verzoek: we gebruiken de "client_credentials" flow, zodat we alleen openbare data kunnen ophalen
$body = @{grant_type = "client_credentials"}

# Voer het verzoek uit om een toegangstoken te verkrijgen
$response = Invoke-RestMethod -Uri $tokenUrl -Method Post -Headers $headers -Body $body
$accessToken = $response.access_token  # Dit token wordt gebruikt voor verdere API-verzoeken

# Stel nieuwe headers in met het toegangstoken
$headers = @{"Authorization" = "Bearer $accessToken"}

# ========================
# **GEWENSTE ARTIESTEN EN NUMMERS INSTELLEN**
# Hier kun je de artiesten en nummers invullen die je zoekt
# ========================
#$artists = @("Eminem", "d12")   # 🔹 Pas deze lijst aan met de gewenste artiesten
#$songs = @("Lose Yourself")  # 🔹 Pas deze lijst aan met de gewenste nummers

$artistsFilePath = "C:\__SCRIPTS\artists.txt"  # Vervang met jouw bestandspad
$songsFilePath = "C:\__SCRIPTS\songs.txt"      # Vervang met jouw bestandspad

# Lees de inhoud van de bestanden en zet deze om in arrays
$artists = Get-Content -Path $artistsFilePath
$songs = Get-Content -Path $songsFilePath

Write-Host "`nArtists to search for: $artists"
Write-Host "Songs to search for: $songs"


# ========================
# **PLAYLISTS ZOEKEN MET DE GEGEVEN ARTIESTEN**
# We zoeken naar playlists die ten minste één van de opgegeven artiesten bevatten.
# ========================
$playlistResults = @()  # Dit zal een lijst bevatten van alle gevonden playlists

foreach ($artist in $artists) {
    # Maak een zoekopdracht voor de huidige artiest
    $searchUrl = "https://api.spotify.com/v1/search?q=$artist&type=playlist&limit=10"
    
    # Voer de zoekopdracht uit en sla de resultaten op
    $response = Invoke-RestMethod -Uri $searchUrl -Method Get -Headers $headers
    $playlistResults += $response.playlists.items  # Voeg alle gevonden playlists toe aan de lijst
}

# ========================
# **FILTER: BEHOUD ALLEEN PLAYLISTS WAARIN ALLE ARTIESTEN VOORKOMEN**
# Omdat de vorige stap aparte zoekopdrachten per artiest uitvoerde, bevat onze lijst nu playlists
# die minstens één van de artiesten bevatten. Nu willen we alleen de playlists behouden
# waarin **alle** artiesten voorkomen.
# ========================
$filteredPlaylists = $playlistResults | Group-Object -Property id | Where-Object { $_.Count -eq $artists.Count } | ForEach-Object { $_.Group }

# ========================
# **CONTROLEREN OF ALLE GEZOCHTE NUMMERS IN DE PLAYLISTS STAAN**
# Nu filteren we verder op basis van de tracklist van elke playlist.
# We zoeken naar playlists waarin **alle** opgegeven nummers voorkomen.
# ========================
$matchedPlaylists = @()  # Hier slaan we de definitieve matches op

foreach ($playlist in $filteredPlaylists) {
    $playlistId = $playlist.id
    $playlistName = $playlist.name
    $playlistUrl = $playlist.external_urls.spotify  # Spotify-link naar de playlist
    $playlistOwner = $playlist.owner.display_name  # De naam van de gebruiker die de playlist heeft gemaakt

    # 🔸 Tracks ophalen voor de playlist
    $tracksUrl = "https://api.spotify.com/v1/playlists/$playlistId/tracks?limit=100"
    $tracksResponse = Invoke-RestMethod -Uri $tracksUrl -Method Get -Headers $headers
    
    # 🔸 Haal alle tracknamen op
    $trackNames = $tracksResponse.items | ForEach-Object { $_.track.name }

    # 🔸 Controleer of ALLE opgegeven nummers in de playlist staan
    $allSongsFound = $songs | ForEach-Object { $trackNames -contains $_ } | Sort-Object -Unique

    if ($allSongsFound.Count -eq $songs.Count) {
        # ✅ Als alle nummers in de playlist staan, voeg deze toe aan de resultatenlijst
        $matchedPlaylists += [PSCustomObject]@{
            Name = $playlistName
            URL = $playlistUrl
            Owner = $playlistOwner  # Toon de eigenaar van de playlist
        }
    }
}


# ========================
# **RESULTATEN WEERGEVEN**
# Laat de gevonden playlists zien, of geef een melding als er geen matches zijn
# ========================
if ($matchedPlaylists.Count -gt 0) {
    Write-Host "`n✅ Playlists with ALL artists and numbers:"
    $matchedPlaylists | Format-Table -Property Owner,Name,URL -AutoSize
} else {
    Write-Host "❌ No playlists found."
}

