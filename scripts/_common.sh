#!/bin/bash

#=================================================
# COMMON VARIABLES AND CUSTOM HELPERS
#=================================================

render_env_file() {
    # Re-render /etc/$app/env from settings, then drop lines whose value is
    # empty so that unset options don't override remark42's own defaults
    # (an empty AUTH_GITHUB_CID= would otherwise be seen as "configured").
    auth_anon_value="false"
    [ "${auth_anon:-no}" = "yes" ] && auth_anon_value="true"

    mkdir -p "/etc/$app"
    ynh_config_add --template="env" --destination="/etc/$app/env"
    sed -i -E '/^[A-Z0-9_]+=$/d' "/etc/$app/env"
    chown root:"$app" "/etc/$app/env"
    chmod 640 "/etc/$app/env"
}

prepare_data_dirs() {
    mkdir -p "$data_dir/backup" "$data_dir/avatars" "$data_dir/pictures" "$data_dir/pictures.staging"
    chown -R "$app:$app" "$data_dir"
    chmod 750 "$data_dir"
}

# The YunoHost admin logs in through remark42's "email magic link" provider;
# their remark42 user id is email_<sha1(email)> (see go-pkgz/auth verify
# provider), which we pre-register in ADMIN_SHARED_ID.
compute_admin_settings() {
    if [ -z "${admin:-}" ]; then
        admin=$(ynh_app_setting_get --key=admin)
    fi
    admin_email=$(ynh_user_get_info --username="$admin" --key=mail)
    admin_id="email_$(printf '%s' "$admin_email" | sha1sum | cut -d' ' -f1)"
}

# Outbound mail authenticates as the app's own sender (resources.system_user
# allow_email): login remark42 / password $mail_pwd on localhost:25, From
# remark42@$domain unless the admin picked another address.
compute_mail_settings() {
    mail_pwd="${mail_pwd:-$(ynh_app_setting_get --key=mail_pwd)}"
    mail_from="${mail_from:-}"
    if [ -z "$mail_from" ]; then
        mail_from="${mail_user:-$app}@${mail_domain:-$domain}"
    fi
}
