<#
.SYNOPSIS
    X (Twitter) Session-Based Authenticated GraphQL Engine.
.DESCRIPTION
    Bypasses paywalled corporate APIs by piggybacking on valid web session tokens (auth_token & ct0).
.EXAMPLE
    .\ScraperAPI.ps1 -AuthToken "a1b2c3d4..." -CsrfToken "e5f6g7h8..."
#>

param (
    [Parameter(Mandatory = \$true)]
    [string]\$AuthToken,  # Extracted from x.com -> Application Storage -> Cookies -> auth_token
    [Parameter(Mandatory = \$true)]
    [string]\$CsrfToken   # Extracted from x.com -> Application Storage -> Cookies -> ct0
)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

Write-Host "[*] Initializing Secure Authenticated GraphQL Client Connection..." -ForegroundColor Cyan

# The immutable Bearer Token used globally by the official X Web Client interface app
\$PublicClientBearer = "Bearer AAAAAAAAAAAAAAAAAAAAANRILgAAAAAAnwIUXJ4oFYKOCSI6pUf%2F91e4%2F38%3D964g9AE7AsgYqSnCHqCthI0g886C36V7AH26v6Nqq3q"

# Construct Request Header Mapping matching legitimate client fingerprints exactly
\$Headers = @{
    "authorization"     = \$PublicClientBearer
    "x-twitter-auth-type"= "OAuth2Session"
    "x-twitter-active-user"="yes"
    "x-csrf-token"      = \$CsrfToken
    "Cookie"            = "auth_token=\(AuthToken; ct0=\)CsrfToken"
    "User-Agent"        = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    "content-type"      = "application/json"
}

# GraphQL Features flag set mimicking exact modern feature gates inside the X frontend layout architecture
\$Variables = @{
    "count" = 20
    "includePromotedContent" = \$false
} | ConvertTo-Json -Compress

\$Features = @{
    "graphql_is_fetching_legacy_interaction_detail" = \$false
    "rweb_tipjar_consumption_enabled" = \$true
    "responsive_web_user_articles_tweet_consumption_enabled" = \$true
    "vibe_api_enabled" = \$true
    "responsive_web_graphql_timeline_navigation_enabled" = \$true
    "responsive_web_graphql_skip_user_profile_image_extensions_enabled" = \$false
    "tweetypie_unmention_optimization_enabled" = \$true
    "responsive_web_edit_tweet_api_enabled" = \$true
    "graphql_is_fetching_legacy_interaction_detail" = \$false
    "view_counts_everywhere_api_enabled" = \$true
    "longform_notetweets_consumption_enabled" = \$true
    "responsive_web_graphql_exclude_directive_enabled" = \$true
    "verified_phone_label_enabled" = \$false
    "freedom_of_speech_not_and_notices_enabled" = \$true
    "standard_features_urt_class_enabled" = \$true
    "tweet_with_visibility_results_prefer_gql_limited_actions_tweet_download_vp_enabled" = \$true
    "responsive_web_media_download_video_playlist_v2_extensions_enabled" = \$false
    "creator_subscriptions_tweet_preview_api_enabled" = \$true
} | ConvertTo-Json -Compress

# Target Query Endpoint String Hash for the Bookmarks Timeline API Route
\$QueryId = "7is9asb6v08K_Y_H891bSA" 
\(Url = "https://x.com\)QueryId/Bookmarks?variables=\(([Uri]::EscapeDataString(\)Variables))&features=\(([Uri]::EscapeDataString(\)Features))"

Write-Host "[*] Sending authenticated fetch token request to X core servers..." -ForegroundColor Yellow

try {
    \$RawResult = Invoke-WebRequest -Uri \(Url -Headers\)Headers -Method Get
    \(JsonResult = ConvertFrom-Json\)RawResult.Content

    # Navigate the high-depth JSON nested data graph returning timeline instructions
    \(Instructions =\)JsonResult.data.bookmark_timeline_v2.timeline.instructions
    
    \$Tweets = @()
    foreach (\(inst in\)Instructions) {
        if (\$inst.type -eq "TimelineAddEntries") {
            foreach (\(entry in\)inst.entries) {
                if (\$entry.entryId -match "tweet-") {
                    try {
                        \(TweetNode =\)entry.content.itemContent.tweet_results.result.legacy
                        \(UserNode =\)entry.content.itemContent.tweet_results.result.core.user_results.result.legacy
                        
                        \$Tweets += [PSCustomObject]@{
                            Author      = \$UserNode.screen_name
                            Name        = \$UserNode.name
                            Text        = \$TweetNode.full_text
                            Likes       = \$TweetNode.favorite_count
                            Retweets    = \$TweetNode.retweet_count
                            Timestamp   = \$TweetNode.created_at
                        }
                    } catch { continue; }
                }
            }
        }
    }

    if (\$Tweets.Count -eq 0) {
        Write-Warning "No recent Bookmarks found or access tokens expired."
    } else {
        Write-Host "`n[SUCCESS] Successfully Extracted $($Tweets.Count) Bookmarks Without API Keys:`n" -ForegroundColor Gold
        \$Tweets | Format-Table Author, Likes, Text -Wrap
    }

} catch {
    Write-Error "Connection rejected or authorization handshake failed. Verify Cookie auth_token and ct0 values."
    if (\$_.Exception.Response) {
        \(Reader = New-Object System.IO.StreamReader(\)_.Exception.Response.GetResponseStream())
        Write-Host "Server Response Error: \((\)Reader.ReadToEnd())" -ForegroundColor Red
    }
}
