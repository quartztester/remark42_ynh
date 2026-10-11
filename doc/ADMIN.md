Remark42 must be installed at the **root of a domain** (e.g. `comments.example.com`): its widget and admin UI hardcode absolute `/api/v1/...` URLs.

Login methods are managed from the app's config panel (anonymous commenting, GitHub/Google OAuth credentials). After changing them, the service is restarted automatically.

The admin account logs in via the **Email magic link**: a confirmation mail is sent to the YunoHost admin's address, and admin rights come pre-granted (`ADMIN_SHARED_ID` is pre-computed from the address hash). Outbound mail uses YunoHost's local postfix on port 25 — make sure the domain's mail is working, otherwise no one can log in except via configured OAuth providers.

Embed snippet for your site (replace the URL):

```html
<div id="remark42"></div>
<script>
  var remark_config = {
    url: location.href, site: "remark",
    server_url: "https://remark42.example.com",
    components: ["embed"],
  };
  (function (c, s) {
    for (var i = 0; i < c.length; i++) {
      var d = document, n = d.createElement("script"),
        f = d.getElementsByTagName("script")[0];
      n.async = !0; n.src = c[i].server_url + "/web/" + c[i].components[i] + ".js";
      f.parentNode.insertBefore(n, f);
    }
  })([remark_config]);
</script>
```

Config lives in `/etc/remark42/env` (managed — regenerate it through the config panel rather than editing by hand). Data: `/home/yunohost.app/remark42`. Logs: `/var/log/remark42/`.
