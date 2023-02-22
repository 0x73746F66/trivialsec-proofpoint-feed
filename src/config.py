import models

feeds: list[models.FeedConfig] = [
    models.FeedConfig(
        name="ipreputation",
        url="https://rules.emergingthreats.net/fwrules/emerging-Block-IPs.txt",
        source="proofpoint.com",
        disabled=False
    ),
    models.FeedConfig(
        name="compromised-ips",
        url="https://rules.emergingthreats.net/blockrules/compromised-ips.txt",
        source="proofpoint.com",
        disabled=False
    ),
]
