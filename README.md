# Spotysearch

#### SearchUsersWithPlaylistsContaining ####
Powershell script that performs OSINT queries on Spotify.
Still very much in development. Functionallies will be added and also user-friendlyness.

History<br>
v0.01 (20250503)<br>
 first POC<br>
v0.02 (20250503)<br>
 Added owner of playlist. <br>
 Added input via txt files instead of hard coded variables<br>
v0.03 (20250507)<br>
 Added input txt files via input (.\spotysearch.ps1 .\artists.txt .\songs.txt)<br>
 Renamed to SearchUsersWithPlaylists <br>
 reset token after stupidly uploading it <br>
<br>
ToDo<br>
<br>
Some testing but that's it
 <br>
 <br>
![screenshot_v002](https://github.com/JeroenVanDenBosch/Spotysearch/blob/main/spotysearch_output_v002.png)
<br>
<br>
To create an API key for Spotify, you need to follow these steps:

Create a Spotify Developer Account:

Go to Spotify for Developers.
Log in with your Spotify account, or create one if you don’t already have one.
Create an Application:

Once logged in, go to the Dashboard.
Click on Create an App.
Fill in the necessary details (like name, description, and website URL). You can use any URL for the website, but it must be in a valid format (even if it’s not your personal site).
Agree to the terms and conditions.
Get Your API Keys:

After creating the app, you will be redirected to the dashboard, where your newly created app is listed.
In the app's settings, you'll see a Client ID and Client Secret.
These are the credentials that act as your "API keys". They are used to authenticate requests to the Spotify API.
Access Tokens (Optional):

To interact with Spotify's APIs and access user data (like their playlists), you’ll need to generate access tokens. This requires OAuth 2.0 authentication.
You can obtain an access token by using the Client ID and Client Secret, and following Spotify's Authorization Guide.
Make sure to keep your Client Secret private, as it’s sensitive information that grants access to your app's API functionality.


<br>
#### SearchUsers ####
<br>
