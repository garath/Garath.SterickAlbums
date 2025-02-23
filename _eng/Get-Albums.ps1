param (
    [string]$Token,
    [string]$Username,
    [string]$Format = "table"  # Default format is "table"
)

# Define the Discogs API endpoint and user token
$apiUrl = "https://api.discogs.com/users/${Username}/collection/folders/0/releases"

# Function to get all LP albums from the Discogs collection
function Get-LPAlbums {
    $headers = @{
        "Authorization" = "Discogs token=$Token"
        "User-Agent" = "Garath.SterickAlbums/0.1.0"
    }

    $lpAlbums = @()

    $page = 1
    $perPage = 100
    $totalPages = 1

    while ($page -le $totalPages) {
        $response = Invoke-RestMethod -Uri "${apiUrl}?page=$page&per_page=$perPage" -Headers $headers -Method Get

        if ($page -eq 1) {
            $totalPages = [math]::Ceiling($response.pagination.items / $perPage)
        }

        foreach ($release in $response.releases) {
            foreach ($Format in $release.basic_information.formats) {
                if ($Format.name -eq "Vinyl") {
                    $id = $release.id
                    $thumbnail = $release.basic_information.thumb
                    $artist = $release.basic_information.artists[0].name
                    $title = $release.basic_information.title
                    $lpAlbums += [pscustomobject]@{
                        Id = $id
                        Thumbnail = $thumbnail
                        Artist = $artist
                        Title = $title
                    }
                }
            }
        }

        $page++
    }

    return $lpAlbums
}

# Get the LP albums
$lpAlbums = Get-LPAlbums

if ($lpAlbums.Count -eq 0) {
    Write-Output "No LP albums found in the collection."
} else {
    if ($format -eq "json") {
        $lpAlbums | ConvertTo-Json | Write-Output
    } else {
        Write-Output "LP Albums in Collection:"
        $lpAlbums | Format-Table -AutoSize
    }
}
