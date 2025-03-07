Param(
    [string]$artistsFilePath,
    [string]$songsFilePath
)

# Ensure both parameters are provided
if (-not $artistsFilePath -or -not $songsFilePath) {
    Write-Host "Usage: .\spotysearch.ps1 <artists.txt> <songs.txt>"
    exit 1
}

# Check if files exist
if (!(Test-Path $artistsFilePath) -or !(Test-Path $songsFilePath)) {
    Write-Host "Error: One or both files do not exist."
    exit 1
}

# Load ASCII art
$asciiArtPath = "C:\__SCRIPTS\spotify_ascii.txt.txt"
if (Test-Path $asciiArtPath) {
    $asciiArt = Get-Content -Path $asciiArtPath -Raw -Encoding utf8
    Write-Host $asciiArt
}

# Spotify API credentials
$clientId = "4cf828fa5ba441ddb1cd53670dc0c552"
$clientSecret = "b852dc241c0c47bfa3af39729dfdf5a7"

# Get access token
$tokenUrl = "https://accounts.spotify.com/api/token"
$headers = @{"Authorization" = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$clientId`:$clientSecret"))}
$body = @{grant_type = "client_credentials"}
$response = Invoke-RestMethod -Uri $tokenUrl -Method Post -Headers $headers -Body $body
$accessToken = $response.access_token
$headers = @{"Authorization" = "Bearer $accessToken"}

# Read artists and songs from files
$artists = Get-Content -Path $artistsFilePath
$songs = Get-Content -Path $songsFilePath
Write-Host "`nArtists to search for: $artists"
Write-Host "Songs to search for: $songs"

# Search for playlists
$playlistResults = @()
foreach ($artist in $artists) {
    $searchUrl = "https://api.spotify.com/v1/search?q=$artist&type=playlist&limit=10"
    $response = Invoke-RestMethod -Uri $searchUrl -Method Get -Headers $headers
    $playlistResults += $response.playlists.items
}

# Filter playlists containing all artists
$filteredPlaylists = $playlistResults | Group-Object -Property id | Where-Object { $_.Count -eq $artists.Count } | ForEach-Object { $_.Group }

# Check for playlists with all songs
$matchedPlaylists = @()
foreach ($playlist in $filteredPlaylists) {
    $playlistId = $playlist.id
    $playlistUrl = $playlist.external_urls.spotify
    $playlistOwner = $playlist.owner.display_name
    
    $tracksUrl = "https://api.spotify.com/v1/playlists/$playlistId/tracks?limit=100"
    $tracksResponse = Invoke-RestMethod -Uri $tracksUrl -Method Get -Headers $headers
    
    $trackNames = $tracksResponse.items | ForEach-Object { $_.track.name }
    $allSongsFound = $songs | ForEach-Object { $trackNames -contains $_ } | Sort-Object -Unique

    if ($allSongsFound.Count -eq $songs.Count) {
        $matchedPlaylists += [PSCustomObject]@{
            Name = $playlist.name
            URL = $playlistUrl
            Owner = $playlistOwner
        }
    }
}

# Display results
if ($matchedPlaylists.Count -gt 0) {
    Write-Host "`n✅ Playlists with ALL artists and numbers:"
    $matchedPlaylists | Format-Table -Property Owner,Name,URL -AutoSize
} else {
    Write-Host "❌ No playlists found."
}
