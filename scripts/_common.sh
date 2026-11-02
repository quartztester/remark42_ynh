#!/bin/bash

#=================================================
# COMMON VARIABLES AND CUSTOM HELPERS
#=================================================

render_env_file() {
    # drop empty lines: unset options must not override remark42's defaults (AUTH_GITHUB_CID= reads as configured)
    auth_anon_value="false"
    [ "${auth_anon:-false}" = "true" ] && auth_anon_value="true"

    mkdir -p "/etc/$app"
    # always render fresh: a leftover env file from an older render triggers
    # ynh_config_add's "manually modified" false alarm on upgrade/restore
    rm -f "/etc/$app/env"
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

# Admin logs in via remark42's email magic link; their remark42 id is
# email_<sha1(email)> (go-pkgz/auth verify provider), pre-registered in ADMIN_SHARED_ID.
compute_admin_settings() {
    if [ -z "${admin:-}" ]; then
        admin=$(ynh_app_setting_get --key=admin)
    fi
    admin_email=$(ynh_user_get_info --username="$admin" --key=mail)
    admin_id="email_$(printf '%s' "$admin_email" | sha1sum | cut -d' ' -f1)"
}

# SMTP as the app's own sender (system_user allow_email): login remark42 /
# $mail_pwd on localhost:25, From remark42@$domain unless admin chose another.
compute_mail_settings() {
    mail_pwd="${mail_pwd:-$(ynh_app_setting_get --key=mail_pwd)}"
    mail_from="${mail_from:-}"
    if [ -z "$mail_from" ]; then
        mail_from="${mail_user:-$app}@${mail_domain:-$domain}"
    fi
}
