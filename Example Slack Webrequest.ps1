$payload = @{
	"channel" = "#monitoring";
	"icon_emoji" = ":bomb:";
	"text" = "This is my message. Hello there!";
	"username" = "SimpleMonitor";
}

Invoke-WebRequest `
	-Uri "https://hooks.slack.com/services/123456789/987654321/NmbVT3YR65mUecmxSvNbpbLqu4MFZnh" `
	-Method "POST" `
	-Body (ConvertTo-Json -Compress -InputObject $payload)