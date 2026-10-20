<img width="1000" height="421" alt="image" src="https://github.com/user-attachments/assets/5f28ef3e-97f1-4c05-806e-1a12f1646d0a" />

# X Cookie Scraper API Client 🧪

An enterprise-grade, low-overhead authenticated GraphQL communication interface designed to interface with internal X (Twitter) core routes without paying for the premium \$100/mo API subscription tier. 

By utilizing secure encrypted web session tokens extracted directly from your personal active browser dashboard, this library facilitates native query processing over endpoints like private Bookmarks, Likes, and advanced User Analytics.

---

## ⚡ Core Architecture

Instead of utilizing standard legacy OAuth application tokens, this package constructs an authenticated client session payload utilizing matching user-agent identifiers, active anti-CSRF handshakes, and official client browser fingerprints.

---

## 🚀 Setup & Session Extraction Guide

To query private authenticated endpoints, you must supply your current valid platform cookies:

1. Open your desktop web browser (Chrome, Edge, Brave, or Firefox) and log into [x.com](https://x.com).
2. Press **F12** or right-click anywhere and choose **Inspect** to initialize the Developer Tools panel.
3. Navigate to the **Application** tab (labeled **Storage/Cookies** on some platforms).
4. Locate the `https://x.com` dropdown menu cluster.
5. Extract and copy the text strings mapped to these two key parameters:
   - `auth_token` (Your primary encrypted authentication state value)
   - `ct0` (Your active cross-site request forgery prevention token)

---

## 💻 Execution Protocol

Run the automated data fetch engine from your local system shell terminal console layer:

```powershell
.\ScraperAPI.ps1 -AuthToken "YOUR_EXTRACTED_AUTH_TOKEN" -CsrfToken "YOUR_EXTRACTED_CT0"
```

## 📊 Available Structural Properties Output

The script maps nested deep-graph JSON models into uniform flat pipeline objects containing:
- **Author handle/username metadata**
- **Full textual payload records**
- **Historical platform timestamps**
- **Engagement analytics telemetry (Likes, Retweets)**

## 🛡️ Security & Anti-Ban Safeguards
This tool executes standard read-only client queries mimicking real human browser interactions. To prevent automated engine detection alarms, the execution pipeline forces natural network sleep thread intervals. Do not hammer endpoints with continuous sub-second requests.
