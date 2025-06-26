-- We need this for prosody 13.0
component_admins_as_room_owners = true

plugin_paths = { "/usr/share/jitsi-meet/prosody-plugins/" }

-- domain mapper options, must at least have domain base set to use the mapper
muc_mapper_domain_base = "jitsi.parthraj.cloud";

external_service_secret = "luUAySAhtaQCdt6m";
external_services = {
     { type = "stun", host = "jitsi.parthraj.cloud", port = 3478 },
     { type = "turn", host = "jitsi.parthraj.cloud", port = 3478, transport = "udp", secret = true, ttl = 86400, algorithm = "turn" },
     { type = "turns", host = "jitsi.parthraj.cloud", port = 5349, transport = "tcp", secret = true, ttl = 86400, algorithm = "turn" }
};

cross_domain_bosh = false;
consider_bosh_secure = true;
consider_websocket_secure = true;
-- https_ports = { }; -- Remove this line to prevent listening on port 5284

-- by default prosody 0.12 sends cors headers, if you want to disable it uncomment the following (the config is available on 0.12.1)
--http_cors_override = {
--    bosh = {
--        enabled = false;
--    };
--    websocket = {
--        enabled = false;
--    };
--}

-- https://ssl-config.mozilla.org/#server=haproxy&version=2.1&config=intermediate&openssl=1.1.0g&guideline=5.4
ssl = {
    protocol = "tlsv1_2+";
    ciphers = "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384"
}

unlimited_jids = {
    "focus@auth.jitsi.parthraj.cloud",
    "jvb@auth.jitsi.parthraj.cloud"
}

-- https://prosody.im/doc/modules/mod_smacks
smacks_max_unacked_stanzas = 5;
smacks_hibernation_time = 60;
smacks_max_old_sessions = 1;

VirtualHost "jitsi.parthraj.cloud"
    authentication = "jitsi-anonymous" -- do not delete me
    -- Properties below are modified by jitsi-meet-tokens package config
    -- and authentication above is switched to "token"
    --app_id="example_app_id"
    --app_secret="example_app_secret"
    -- Assign this host a certificate for TLS, otherwise it would use the one
    -- set in the global section (if any).
    -- Note that old-style SSL on port 5223 only supports one certificate, and will always
    -- use the global one.
    ssl = {
        key = "/etc/prosody/certs/jitsi.parthraj.cloud.key";
        certificate = "/etc/prosody/certs/jitsi.parthraj.cloud.crt";
    }
    av_moderation_component = "avmoderation.jitsi.parthraj.cloud"
    speakerstats_component = "speakerstats.jitsi.parthraj.cloud"
    end_conference_component = "endconference.jitsi.parthraj.cloud"
    -- we need bosh
    modules_enabled = {
        "bosh";
        "websocket";
        "smacks";
        "ping"; -- Enable mod_ping
        "speakerstats";
        "external_services";
        "conference_duration";
        "end_conference";
        "muc_lobby_rooms";
        "muc_breakout_rooms";
        "av_moderation";
        "room_metadata";
    }
    c2s_require_encryption = false
    lobby_muc = "lobby.jitsi.parthraj.cloud"
    breakout_rooms_muc = "breakout.jitsi.parthraj.cloud"
    room_metadata_component = "metadata.jitsi.parthraj.cloud"
    muc_lobby_whitelist = { "recorder.jitsi.parthraj.cloud" }
    main_muc = "conference.jitsi.parthraj.cloud"
    -- muc_lobby_whitelist = { "recorder.jitsi.parthraj.cloud" } -- Here we can whitelist jibri to enter lobby enabled rooms

Component "conference.jitsi.parthraj.cloud" "muc"
    restrict_room_creation = true
    storage = "memory"
    modules_enabled = {
        "muc_hide_all";
        "muc_meeting_id";
        "muc_domain_mapper";
        "polls";
        --"token_verification";
        "muc_rate_limit";
        "muc_password_whitelist";
    }
    admins = { "focus@auth.jitsi.parthraj.cloud" }
    muc_password_whitelist = {
        "focus@auth.jitsi.parthraj.cloud"
    }
    muc_room_locking = false
    muc_room_default_public_jids = true

Component "breakout.jitsi.parthraj.cloud" "muc"
    restrict_room_creation = true
    storage = "memory"
    modules_enabled = {
        "muc_hide_all";
        "muc_meeting_id";
        "muc_domain_mapper";
        "muc_rate_limit";
        "polls";
    }
    admins = { "focus@auth.jitsi.parthraj.cloud" }
    muc_room_locking = false
    muc_room_default_public_jids = true

-- internal muc component
Component "internal.auth.jitsi.parthraj.cloud" "muc"
    storage = "memory"
    modules_enabled = {
        "muc_hide_all";
        "ping";
    }
    admins = { "focus@auth.jitsi.parthraj.cloud", "jibri@auth.jitsi.parthraj.cloud","jvb@auth.jitsi.parthraj.cloud" }
    muc_room_locking = false
    muc_room_default_public_jids = true

VirtualHost "auth.jitsi.parthraj.cloud"
    ssl = {
        key = "/etc/prosody/certs/auth.jitsi.parthraj.cloud.key";
        certificate = "/etc/prosody/certs/auth.jitsi.parthraj.cloud.crt";
    }
    modules_enabled = {
        "limits_exception";
        "smacks";
    }
    authentication = "internal_hashed"
    smacks_hibernation_time = 15;

--VirtualHost "recorder.jitsi.parthraj.cloud"
--    modules_enabled = {
--        "smacks";
--    }
--    authentication = "internal_hashed"
--    smacks_max_old_sessions = 2000;


-- Proxy to jicofo's user JID, so that it doesn't have to register as a component.
Component "focus.jitsi.parthraj.cloud" "client_proxy"
    target_address = "focus@auth.jitsi.parthraj.cloud"

Component "speakerstats.jitsi.parthraj.cloud" "speakerstats_component"
    muc_component = "conference.jitsi.parthraj.cloud"

Component "endconference.jitsi.parthraj.cloud" "end_conference"
    muc_component = "conference.jitsi.parthraj.cloud"

Component "avmoderation.jitsi.parthraj.cloud" "av_moderation_component"
    muc_component = "conference.jitsi.parthraj.cloud"

Component "recorder.jitsi.parthraj.cloud" "internal_component"
    storage = "memory"
    muc_component = "conference.jitsi.parthraj.cloud"


Component "lobby.jitsi.parthraj.cloud" "muc"
    storage = "memory"
    restrict_room_creation = true
    muc_room_locking = false
    muc_room_default_public_jids = true
    modules_enabled = {
        "muc_hide_all";
        "muc_rate_limit";
        "polls";
    }

Component "metadata.jitsi.parthraj.cloud" "room_metadata_component"
    muc_component = "conference.jitsi.parthraj.cloud"
    breakout_rooms_component = "breakout.jitsi.parthraj.cloud"
